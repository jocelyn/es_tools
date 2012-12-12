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
			s: STRING_32
		do
			wd := execution_environment.current_working_path
			curr_ise_eiffel := execution_environment.item ("ISE_EIFFEL")
			v_platform := execution_environment.item ("ISE_PLATFORM")
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

			create s.make_empty
			l_path := execution_environment.item ("PATH")
			if {PLATFORM}.is_windows then
				s.append_string_general ("set ISE_EIFFEL=")
				s.append (wd.name)
			else
				s.append_string_general ("export ISE_EIFFEL=")
				s.append (wd.name)
			end
			s.append_character ('%N')

			if {PLATFORM}.is_windows then
				s.append_string_general ("set PATH=")
			else
				s.append_string_general ("export PATH=")
			end

			l_new := wd.extended ("studio").extended ("spec").extended (v_platform).extended ("bin")

			if l_path /= Void and l_old /= Void then
				l_path.replace_substring_all (l_old.name, l_new.name)
				if curr_ise_eiffel /= Void then
					l_path.replace_substring_all (curr_ise_eiffel, wd.name)
				end
				s.append (l_path)
			else
				s.append (l_new.name)
				if {PLATFORM}.is_windows then
					s.append_string_general (";%%PATH%%")
				else
					s.append_string_general (":$PATH")
				end
			end
			s.append_character ('%N')
			save_script (s)
		end

	save_script (s: STRING_32)
		local
			f: RAW_FILE
			utf: UTF_CONVERTER
			t: STRING_32
			s8: STRING_8
		do
			if {PLATFORM}.is_windows then
				create f.make_with_path (execution_environment.current_working_path.extended ("tmp_set_eiffel.bat"))
			else
				create f.make_with_path (execution_environment.current_working_path.extended ("tmp_set_eiffel.rc"))
			end
			f.create_read_write
			if {PLATFORM}.is_windows then
				f.put_string (utf.utf_8_bom_to_string_8)
--				f.put_string (utf.utf_16le_bom_to_string_8)
				create t.make_empty
				t.append_string_general ("%Nrem Setting ISE_EIFFEL ...%N")
				t.append (s)
				t.append_character ('%N')
				t.replace_substring_all ("%N", "%R%N")
				create s8.make_empty
				utf.escaped_utf_32_string_into_utf_8_string_8 (t, s8)
--				utf.escaped_utf_32_string_into_utf_16le_string_8 (t, s8)
				f.put_string (s8)

			else
				f.put_string (utf.utf_8_bom_to_string_8)
				create t.make_empty
				t.append_string_general ("%N# Setting ISE_EIFFEL ...%N")
				t.append (s)
				create s8.make_empty
				utf.escaped_utf_32_string_into_utf_8_string_8 (t, s8)
				f.put_string (s8)
			end
			f.close
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			printer.localized_print ("Help: set ISE_EIFFEL to current path")
			io.put_new_line
		end

end
