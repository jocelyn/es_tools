note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	SET_EIFFEL_COMMAND

inherit
	ES_COMMAND_WITH_HELP

	SHARED_EXECUTION_ENVIRONMENT

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "set ISE_EIFFEL to current path"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			wd: PATH
			curr_ise_eiffel: detachable STRING_32
			v_platform: detachable STRING_32
			l_new, l_old: detachable PATH
			l_path: detachable STRING_32
			args: LIST [READABLE_STRING_32]
			arg: READABLE_STRING_32
			l_output_file: detachable PATH
			l_exec_args: detachable ARRAYED_LIST [READABLE_STRING_32]
			l_script: ENV_SCRIPT
		do
			args := ctx.arguments
			from
				args.start
			until
				args.after
			loop
				arg := args.item
				if arg.starts_with_general ("-") then
					if arg.is_case_insensitive_equal_general ("--file") then
						args.forth
						if args.after then
							if {PLATFORM}.is_windows then
								l_output_file := execution_environment.current_working_path.extended ("tmp_set_eiffel.bat")
							else
								l_output_file := execution_environment.current_working_path.extended ("tmp_set_eiffel.rc")
							end
						else
							create l_output_file.make_from_string (args.item)
							if not l_output_file.is_absolute then
								l_output_file := execution_environment.current_working_path.extended_path (l_output_file)
							end
						end
					end
				else
					if l_exec_args = Void then
						create l_exec_args.make (args.count)
					end
					l_exec_args.force (arg)
				end
				args.forth
			end

			wd := execution_environment.current_working_path
			curr_ise_eiffel := execution_environment.item ("ISE_EIFFEL")
			v_platform := execution_environment.item ("ISE_PLATFORM")

			create l_script.make (3)

			if curr_ise_eiffel /= Void and v_platform /= Void then
				create l_old.make_from_string (curr_ise_eiffel)
				l_old := l_old.extended ("studio").extended ("spec").extended (v_platform).extended ("bin")
			end
			if v_platform = Void then
				if {PLATFORM}.is_windows then
					v_platform := "win64"
				else
					v_platform := "linux-x86-64"
				end
			end

			l_path := execution_environment.item ("PATH")
			l_script.assign_variable ("ISE_EIFFEL", {ENV_SCRIPT}.string (wd.name))

			l_new := wd.extended ("studio").extended ("spec").extended (v_platform).extended ("bin")

			if l_path /= Void and l_old /= Void then
				l_path.replace_substring_all (l_old.name, l_new.name)
				if curr_ise_eiffel /= Void then
					l_path.replace_substring_all (curr_ise_eiffel, wd.name)
				end
				l_script.assign_variable ("PATH", {ENV_SCRIPT}.string (l_path))
			else

				l_script.assign_variable ("PATH", {ENV_SCRIPT}.path (
						{ARRAY [ENV_VALUE]} << {ENV_SCRIPT}.string (wd.extended ("tools").extended ("spec").extended (v_platform).extended ("bin").name),
												{ENV_SCRIPT}.variable ("PATH")>>
										)
									)
				l_script.assign_variable ("PATH", {ENV_SCRIPT}.path ({ARRAY [ENV_VALUE]} <<{ENV_SCRIPT}.string (l_new.name), {ENV_SCRIPT}.variable ("PATH")>>))
			end
			if l_output_file /= Void then
				save_script (l_script, l_output_file)
			elseif l_exec_args /= Void and then not l_exec_args.is_empty then
				execute_script (l_script, l_exec_args)
			else
				output_script (l_script)
			end
		end

	execute_script (a_script: ENV_SCRIPT; a_exec_params: ITERABLE [READABLE_STRING_GENERAL])
		local
			cmd: detachable READABLE_STRING_GENERAL
			args: ARRAYED_LIST [ENV_STRING_VALUE]
			tmp: PATH
			f: RAW_FILE
		do
			across
				a_exec_params as ic
			loop
				if cmd = Void then
					cmd := ic.item
				else
					if args = Void then
						create args.make (1)
					end
					args.force ({ENV_SCRIPT}.string (ic.item))
				end
			end
			if cmd /= Void then
				a_script.add_call ({ENV_SCRIPT}.string (cmd), args)

				if {PLATFORM}.is_windows then
					tmp := execution_environment.current_working_path.extended (".tmp-set-eiffel.bat")
					a_script.add_call ({ENV_SCRIPT}.string ("del"), <<{ENV_SCRIPT}.string (tmp.name)>>)
				else
					tmp := execution_environment.current_working_path.extended (".tmp-set-eiffel.sh")
					a_script.add_call ({ENV_SCRIPT}.string ("rm"), <<{ENV_SCRIPT}.string (tmp.name)>>)
				end
				save_script (a_script, tmp)
				create f.make_with_path (tmp)
				f.add_permission ("u", "x")
				execution_environment.system (tmp.name)
			end
		end

	output_script (a_script: ENV_SCRIPT)
		local
			p: ENV_WINDOWS_PRINTER
			s: STRING_32
		do
			create s.make_empty
			create p.make (s)
			p.visit_script (a_script)
			localized_print (s)
		end

	save_script (a_script: ENV_SCRIPT; a_filename: PATH)
		local
			f: RAW_FILE
			utf: UTF_CONVERTER
			p: ENV_WINDOWS_PRINTER
			s: STRING_32
		do
			create s.make_empty
			create p.make (s)
			({ENV_SCRIPT}.comment ("Set Eiffel environment") + a_script).accept (p)

			create f.make_with_path (a_filename)
			f.create_read_write
			f.put_string (utf.utf_8_bom_to_string_8)

			if {PLATFORM}.is_windows then
				s.append_character ('%N')
				s.replace_substring_all ("%N", "%R%N")
			end
			f.put_string (utf.utf_32_string_to_utf_8_string_8 (s))
			f.close
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			localized_print ("Help: set ISE_EIFFEL to current path")
			io.put_new_line
		end

end
