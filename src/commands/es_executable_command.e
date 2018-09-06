note
	description: "Summary description for {ES_EXECUTABLE_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_EXECUTABLE_COMMAND

inherit
	ES_COMMAND

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make (a_executable_name: PATH)
		do
			executable := a_executable_name
		end

feature -- Access		

	executable: PATH

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		local
			f: RAW_FILE
		do
			if not is_disabled then
				create f.make_with_path (resolved_executable_path)
				Result := f.exists
			end
		end

	is_path_executable: BOOLEAN
			-- Is current path executable?
		local
			f: RAW_FILE
		do
			create f.make_with_path (resolved_executable_path)
			Result := f.exists and then f.is_executable -- FIXME: why not is_access_executable ?
		end

	is_disabled: BOOLEAN
			-- Is command disabled?
			--| usually by configuration.

feature -- Access

	description: detachable IMMUTABLE_STRING_32

	arguments: detachable READABLE_STRING_32
			-- Optional arguments

feature -- Change

	set_executable_path (p: PATH)
		do
			executable := p
		end

	set_description (d: like description)
		do
			description := d
		end

	set_arguments (args: like arguments)
		do
			arguments := args
		end

	set_status (s: READABLE_STRING_GENERAL)
		do
			if s.is_case_insensitive_equal ("disabled") then
				is_disabled := True
			end
		end

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		local
			s: STRING_32
			o: detachable STRING_8
		do
			create s.make_from_string (resolved_executable_path.name)
			if attached arguments as args then
				s.append_character (' ')
				s.append_string_general (args)
			end
			across
				ctx.arguments as c
			loop
				s.append_character (' ')
				s.append_string_general (c.item)
			end
			if ctx.is_verbose then
				localized_print ({STRING_32} "Executing " + s + "%N")
			end

--			create o.make (255)
			execute_command (s, Void, o)
			if o /= Void then
				io.put_string (o)
			end
		end

feature {NONE} -- Implementation

	resolved_executable_path: PATH
		require
			is_available: is_available
		local
			u: ENVIRONMENT_PATH_UTILITIES
			f: RAW_FILE
		do
			Result := executable
			create f.make_with_path (executable)
			if f.exists and then f.is_access_executable then
				Result := executable
			elseif executable.parent = Void then
					-- Do not resolved  foo/bar .. since it is about a precise path
				create u
				if attached u.absolute_executable_path (executable) as p then
					f.reset_path (p)
					if f.exists and then f.is_executable then
						Result := p
					end
				end
			end
		end

	execute_command (a_cmd: READABLE_STRING_GENERAL; a_dir: detachable READABLE_STRING_GENERAL; a_buffer: detachable STRING_8)
			-- Output of command `a_cmd' launched in directory `a_dir'.
		require
			cmd_attached: a_cmd /= Void
		local
			pf: PROCESS_FACTORY
			p: PROCESS
			retried: BOOLEAN
			err: BOOLEAN
		do
			if not retried then
				err := False
				create pf

				if
					not is_path_executable and then
					{PLATFORM}.is_windows and then
					attached execution_environment.item ("ComSpec") as l_comspec
				then
					p := pf.process_launcher_with_command_line (l_comspec + " /C " + a_cmd.to_string_32, a_dir)
				else
					p := pf.process_launcher_with_command_line (a_cmd, a_dir)
				end
--				p.set_timer (create {PROCESS_THREAD_TIMER}.make (1))
				p.set_hidden (True)
				p.set_separate_console (False)
				if a_buffer /= Void then
--					p.redirect_input_to_stream				
					p.redirect_output_to_agent (agent  (res: STRING; s: STRING)
						do
							res.append_string (s)
						end (a_buffer, ?)
					)
					p.redirect_error_to_same_as_output
				end
				p.launch
				p.wait_for_exit
			else
				err := True
			end
		rescue
			retried := True
			retry
		end

end
