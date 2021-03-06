note
	description: "Summary description for {ES_COMMAND_MANAGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_COMMAND_MANAGER

inherit
	TABLE_ITERABLE [ES_COMMAND, READABLE_STRING_GENERAL]

	LOCALIZED_PRINTER

create
	make


feature {NONE} -- Initialization

	make
		do
			create items.make (0)
			create observers.make (0)
		end

feature -- Access

	logo: STRING_32
		do
			create Result.make (32)
			Result.append ({ES_TOOL_CONSTANTS}.product_name)
			Result.append (" (version:")
			Result.append ({ES_TOOL_CONSTANTS}.version_major.out)
			Result.append (".")
			Result.append ({ES_TOOL_CONSTANTS}.version_minor.out)
			Result.append (")")
		end

feature -- Callback

	on_path_import (p: PATH)
		do
			across
				observers as ic
			loop
				ic.item.on_path_import (p)
			end
		end

	on_command_registered (cmd: ES_COMMAND; a_name: READABLE_STRING_GENERAL)
		do
			across
				observers as ic
			loop
				ic.item.on_command_registered (cmd, a_name)
			end
		end

	observers: ARRAYED_LIST [ES_COMMAND_MANAGER_OBSERVER]

feature -- Change

	register (cmd: ES_COMMAND; a_name: READABLE_STRING_GENERAL)
		local
			g: ES_GROUP_COMMAND
			n,s: STRING_32
			p: INTEGER
		do
			on_command_registered (cmd, a_name)
			n := a_name.to_string_32
			p := n.index_of ({ES_TOOL_CONSTANTS}.group_separator, 1)
			if p > 0 then
				s := n.substring (p + 1, n.count)
				n.keep_head (p - 1)
				if attached command (n) as c then
					if attached {ES_GROUP_COMMAND} c as l_parent then
						l_parent.register (cmd, s)
					elseif attached {ES_PATH_GROUP_COMMAND} c as l_path_grp then
						localized_print_error ({STRING_32} "ERROR with %"" + a_name.to_string_8 + {STRING_32} "%": [" + n + "] already found at " + l_path_grp.path.name + {STRING_32} "!!!%N")
					else
						localized_print_error ({STRING_32} "ERROR with %"" + a_name.to_string_8 + {STRING_32} "%": [" + n + "] already registered (" + c.debug_output + ")!!!%N")
					end
				else
					create g.make
					items.force (g, n)
					g.register (cmd, s)
				end
			else
				items.force (cmd, n)
			end
		end

	import (a_path: PATH)
			-- Import config file at `a_path`.
		local
			f: PLAIN_TEXT_FILE
			l_line: STRING_8
			i: INTEGER
			utf: UTF_CONVERTER
			cmd: detachable ES_EXECUTABLE_COMMAND
			l_name: detachable STRING_8
			s,v: STRING_8
			p: PATH
			str_exp: STRING_ENVIRONMENT_EXPANDER
		do
			on_path_import (a_path)
			debug
				print ("Import " + a_path.name + "%N")
			end
			create f.make_with_path (a_path)
			if f.exists and then f.is_readable then
				create str_exp
				f.open_read
				from
					f.read_line_thread_aware
					l_line := f.last_string
					if l_line.starts_with (utf.utf_8_bom_to_string_8) then
						l_line.remove_head (utf.utf_8_bom_to_string_8.count)
					end
				until
					f.exhausted
				loop
					l_line.left_adjust
					if l_line.is_empty or l_line.starts_with ("#") then
							-- commented line -> ignore
					elseif l_line.starts_with_general ("@include=") then
						v := l_line.substring (("@include=").count + 1, l_line.count)
						v.left_adjust
						v.right_adjust
						create p.make_from_string (str_exp.expand_string_32 (utf.utf_8_string_8_to_string_32 (v), True))
						if not p.is_absolute and then attached a_path.parent as l_parent then
							p := l_parent.extended_path (p)
						end
						import (p.canonical_path)
					else
						if l_line.starts_with ("[") then
								-- New command declaration.
							if l_name /= Void and cmd /= Void then
								register (cmd, l_name)
							end
							l_line.right_adjust
							l_name := l_line.substring (2, l_line.count - 1)
							l_name.left_adjust
							l_name.right_adjust
							if l_name.same_string ("*") then
									-- '*' , usually redirect to a path
								cmd := Void
							else
								create cmd.make (create {PATH}.make_from_string (l_name))
							end
						elseif cmd /= Void then
							i := l_line.index_of ('=', 1)
							if i > 0 then
								s := l_line.substring (1, i - 1)
								s.right_adjust
								if s.same_string ("path") then
									s := l_line.substring (i + 1, l_line.count)
									s.left_adjust
									s.right_adjust
									create p.make_from_string (str_exp.expand_string_32 (utf.utf_8_string_8_to_string_32 (s), True))
									if not p.is_absolute and then attached a_path.parent as l_parent then
										p := l_parent.extended_path (p)
									end
									cmd.set_executable_path (p.canonical_path)
--								elseif s.same_string ("command") then
--									s := l_line.substring (i + 1, l_line.count)
--									cmd.set_command (str_exp.expand_string_32 (utf.utf_8_string_8_to_string_32 (s), True))
								elseif s.same_string ("description") then
									s := l_line.substring (i + 1, l_line.count)
									s.left_adjust
									s.right_adjust
									cmd.set_description (utf.utf_8_string_8_to_string_32 (s))
								elseif s.same_string ("arguments") then
									s := l_line.substring (i + 1, l_line.count)
									s.left_adjust
									s.right_adjust
									cmd.set_arguments (utf.utf_8_string_8_to_string_32 (s))
								elseif s.same_string ("status") then
									s := l_line.substring (i + 1, l_line.count)
									s.left_adjust
									s.right_adjust
									cmd.set_status (s)
								end
							end
						elseif l_name /= Void and then l_name.same_string ("*") then
							check cmd = Void end
							i := l_line.index_of ('=', 1)
							if i > 0 then
								s := l_line.substring (1, i - 1)
								s.right_adjust
								if s.same_string ("path") then
										-- Import all from associated path
									s := l_line.substring (i + 1, l_line.count)
									s.left_adjust
									s.right_adjust
									create p.make_from_string (str_exp.expand_string_32 (utf.utf_8_string_8_to_string_32 (s), True))
									if not p.is_absolute and then attached a_path.parent as l_parent then
										p := l_parent.extended_path (p)
									end
									import_all_from (p.canonical_path)
								end
							end
						end
					end
					f.read_line_thread_aware
					l_line := f.last_string
				end
				f.close
				if l_name /= Void and cmd /= Void then
					register (cmd, l_name)
				end
			end
		end

	import_all_from (a_dir: PATH)
		require
			a_dir_exists: (create {DIRECTORY}.make_with_path (a_dir)).exists
		local
			f: PLAIN_TEXT_FILE
			s,n,v: STRING_32
			l_name: detachable STRING_32
			i: INTEGER
			p,fn: PATH
			dir, d: DIRECTORY
			cmd: ES_EXECUTABLE_COMMAND
			menu: ES_PATH_GROUP_COMMAND
			utf: UTF_CONVERTER
		do
			on_path_import (a_dir)
			import (a_dir.extended ({ES_TOOL_CONSTANTS}.es_ini_filename))

			create dir.make_with_path (a_dir)
			if dir.exists and then dir.is_readable then
				dir.open_read
				across
					dir.entries as c
				loop
					p := c.item
					if p.is_current_symbol or p.is_parent_symbol then
					else
						p := a_dir.extended_path (p)
						create d.make_with_path (p)
						if d.exists and then d.is_readable then
							create menu.make (p)
							register (menu, c.item.name)
						else
							s := p.name
							if attached p.extension as ext and then ext.is_case_insensitive_equal_general ({ES_TOOL_CONSTANTS}.es_info_extension) then
								create f.make_with_path (p)
								if f.exists and then f.is_access_readable then
									create fn.make_from_string (s.substring (1, s.count - 1 - {ES_TOOL_CONSTANTS}.es_info_extension.count))
									f.reset_path (fn)
									if not f.exists and {PLATFORM}.is_windows then
										fn := fn.appended_with_extension ("exe")
										f.reset_path (fn)
									end
									if f.exists then
										f.reset_path (p)
										f.open_read
										from
											create cmd.make (fn)
											--| Get name from file entry name
											if attached fn.entry as fn_entry then
												l_name := fn_entry.name
												i := l_name.last_index_of ('.', l_name.count)
												if i > 0 then
													l_name.keep_head (i - 1)
												end
											end
											f.read_line_thread_aware
											s := f.last_string
											if s.starts_with (utf.utf_8_bom_to_string_8) then
												s.remove_head (utf.utf_8_bom_to_string_8.count)
											end
										until
											f.exhausted
										loop
											s.left_adjust
											if s.starts_with ("#") then
												-- Ignore commented lines
											else
												i := s.index_of ('=', 1)
												if i > 0 then
													n := s.substring (1, i - 1)
													if n.same_string ("description") then
														cmd.set_description (s.substring (i + 1, s.count))
													elseif n.same_string ("name") then
														l_name := s.substring (i + 1, s.count)
													elseif n.same_string ("arguments") then
														cmd.set_arguments (s.substring (i + 1, s.count))
													elseif n.same_string ("status") then
														v := s.substring (i + 1, s.count)
														v.left_adjust
														v.right_adjust
														cmd.set_status (v)
													end
												end
											end
											f.read_line_thread_aware
											s := f.last_string
										end
										f.close
										if l_name /= Void and then not l_name.is_empty then
											register (cmd, l_name)
										end
									end
								end
							end
						end
					end
				end
				dir.close
			end
		end

feature  -- Access

	command (n: READABLE_STRING_GENERAL): detachable ES_COMMAND
		do
			Result := items.item (n)
		end

	count: INTEGER
		do
			Result := items.count
		end

feature -- Status report

	is_empty: BOOLEAN
		do
			Result := count = 0
		end

feature {NONE} -- Access

	items: STRING_TABLE [ES_COMMAND]

feature -- Cursor

	new_cursor: TABLE_ITERATION_CURSOR [ES_COMMAND, READABLE_STRING_GENERAL]
			-- Fresh cursor associated with current structure
		do
			Result := items.new_cursor
		end

end
