note
	description: "Summary description for {ENVIRONMENT_PATH_UTILITIES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENVIRONMENT_PATH_UTILITIES

inherit
	SHARED_EXECUTION_ENVIRONMENT

feature -- Access

	absolute_executable_path (a_path: PATH): detachable PATH
		do
			if attached list_of_path_containing_executable (a_path, 1) as lst and then not lst.is_empty then
				Result := lst.first
			end
		ensure
			Result /= Void implies Result.is_absolute
		end

	list_of_path_containing_executable (a_path: PATH; nb: INTEGER): detachable LIST [PATH]
		local
			f: RAW_FILE
			exe_name: PATH
			check_is_executable: BOOLEAN
			has_extension: BOOLEAN
			l_names: detachable ARRAYED_LIST [PATH]
			exe_name_str: STRING_32
		do
			create {ARRAYED_LIST [PATH]} Result.make (1)

			exe_name := a_path
			create l_names.make (1)
			l_names.extend (exe_name)
			if {PLATFORM}.is_windows then
				check_is_executable := False
				if attached execution_environment.item ("PATHEXT") as l_pathext then
					exe_name_str := exe_name.name
					across
						l_pathext.split (';') as e
					until
						has_extension
					loop
						if not exe_name_str.substring (exe_name_str.count - e.item.count, exe_name_str.count).is_case_insensitive_equal_general (e.item) then
							l_names.extend (create {PATH}.make_from_string (exe_name_str + e.item.as_lower))
						else
							has_extension := True
							l_names.wipe_out
							l_names.extend (exe_name)
						end
					end
				end
			else
				check_is_executable := True
			end

			create f.make_with_path (exe_name)
			across
				l_names as n
			until
				nb > 0 and then Result.count >= nb
			loop
				f.reset_path (n.item)
				if
					n.item.is_absolute and f.exists and then
					(check_is_executable implies f.is_executable) -- FIXME: why not is_access_executable?
				then
					Result.extend (n.item)
				end
			end
			if ((nb = 0) or (nb > 0 and Result.count < nb)) and attached environment_paths as lst then
				if {PLATFORM}.is_windows then
					lst.start
					lst.put (execution_environment.current_working_path)
				end
				across
					lst as c
				until
					nb > 0 and then Result.count >= nb
				loop
					across
						l_names as n
					until
						nb > 0 and then Result.count >= nb
					loop
						f.reset_path (c.item.extended_path (n.item))
						if
							f.exists and then
							(check_is_executable implies f.is_executable) -- FIXME: why not is_access_executable?
						then
							Result.extend (f.path.canonical_path)
						end
					end
				end
			end
			if Result.is_empty then
				Result := Void
			end
		ensure
			Result /= Void implies (not Result.is_empty and (nb = 0 or else Result.count <= nb))
		end

	environment_paths: detachable LIST [PATH]
		local
			lst: LIST [STRING_32]
		do
			if attached execution_environment.item ("PATH") as env_path then
				if {PLATFORM}.is_windows then
					lst := env_path.split (';')
				else
					lst := env_path.split (':')
				end
				create {ARRAYED_LIST [PATH]} Result.make (lst.count)
				across
					lst as c
				loop
					Result.force (create {PATH}.make_from_string (c.item))
				end
			end
		end

end
