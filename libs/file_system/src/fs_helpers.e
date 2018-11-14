note
	description: "[
			Objects that ...
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	FS_HELPERS

feature -- Access

	files_changes_count: INTEGER

	files_count: INTEGER

	directories_count: INTEGER

	is_verbose: BOOLEAN

	is_simulation: BOOLEAN

feature -- Options

	is_recursive: BOOLEAN

feature -- Status

	path_excluded (pn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is Path `pn' excluded?
			--| this can be a directory or a file
		require
			pn_is_simple: pn.is_simple
		do
			Result := pn.is_current_symbol or pn.is_parent_symbol
		end

	directory_excluded (dn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is Directory `dn' excluded?
		require
			dn_is_simple: dn.is_simple
			path_not_excluded: not path_excluded (dn, a_parent_directory)
		do
			Result := False
		end

	file_excluded (fn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is file `fn' excluded?
		require
			fn_is_simple: fn.is_simple
			path_not_excluded: not path_excluded (fn, a_parent_directory)
		do
			Result := False
		end

feature -- Element change

	set_is_verbobse (b: BOOLEAN)
		do
			is_verbose := b
		end

	reset
		do
			files_count := 0
			files_changes_count := 0
			directories_count := 0
		end

feature -- System/process files

	process (dn: PATH; on_file_action: PROCEDURE [PATH]; on_ignore_action: detachable PROCEDURE [PATH])
		local
			entry: PATH
			l_path: PATH
			l_file: FILE
			ut: FILE_UTILITIES
			d: DIRECTORY
		do
			directories_count := directories_count + 1
			create d.make_with_path (dn)
			across
				d.entries as ic
			loop
				entry := ic.item
				if not (entry.is_current_symbol or else entry.is_parent_symbol) then
					if path_excluded (entry, dn) then
						if on_ignore_action /= Void then
							l_path := dn.extended_path (entry)
							on_ignore_action (l_path)
						end
					else
						l_path := dn.extended_path (entry)
						create {RAW_FILE} l_file.make_with_path (l_path)
						if l_file.is_directory then
							if is_recursive then
								if 
									not directory_excluded (entry, dn) and then
									ut.directory_path_exists (l_path)
								then
										-- Is included Directory
									process (l_path, on_file_action, on_ignore_action)
								else
									if on_ignore_action /= Void then
										on_ignore_action (l_path)
									end
								end
							end
						else
								-- Is File
							if file_excluded (entry, dn) then
								if on_ignore_action /= Void then
									on_ignore_action (l_path)
								end
							else
								on_file_action (l_path)
							end
						end
					end
				end
			end
		end

feature -- System/copy files

	copy_directory (a_src: DIRECTORY; a_dest: DIRECTORY)
			-- Copy all elements from `a_src' to `a_dest'.
		local
			l_dir: DIRECTORY
			l_new_dir: DIRECTORY
			entry: PATH
			dn, l_path: PATH
			l_file: FILE
			ut: FILE_UTILITIES
		do
			directories_count := directories_count + 1
			dn := a_src.path
			across
				a_src.entries as ic
			loop
				entry := ic.item
				if not (entry.is_current_symbol or else entry.is_parent_symbol) then
					if not path_excluded (entry, dn) then
						l_path := dn.extended_path (entry)
						create {RAW_FILE} l_file.make_with_path (l_path)
						if l_file.is_directory then
							if
								is_recursive and then
								not directory_excluded (entry, dn) and then
								ut.directory_path_exists (l_path)
							then
									-- Is Directory
								create l_dir.make_with_path (l_path)
								create l_new_dir.make_with_path (a_dest.path.extended_path (entry))
								if not is_simulation then
									ut.create_directory_path (l_new_dir.path)
								end
								if l_dir.exists then
									copy_directory (l_dir, l_new_dir)
								end
							end
						else
								-- Is File
							if not file_excluded (entry, dn) then
								copy_file_in_directory (l_file, a_dest.path)
							end
						end
					end
				end
			end
		end

	copy_file_in_directory (a_file: FILE; a_dir: PATH)
			-- Copy file `a_file' to dir `a_dir'.
		local
			retried: BOOLEAN
			l_dest: RAW_FILE
		do
			if not retried then
				if attached a_file.path.entry as e then
					a_file.open_read
						-- Copy file source to destination
					if
						a_file.exists and then
						a_file.is_access_readable
					then
						create l_dest.make_with_path (a_dir.extended_path (e))
						if
							not l_dest.exists or else
							l_dest.is_writable
						then
							if not l_dest.exists or else (a_file.date > l_dest.date) then
								files_changes_count := files_changes_count + 1
								if is_verbose then
									print ({STRING_32} " - file %"" + l_dest.path.name + "%"%N")
								end
							end

							if not is_simulation then
								l_dest.create_read_write
								a_file.copy_to (l_dest)
								a_file.close
								l_dest.close
							end
							files_count := files_count + 1
						end
					end
				end
			end
		rescue
			retried := True
			retry
		end

end
