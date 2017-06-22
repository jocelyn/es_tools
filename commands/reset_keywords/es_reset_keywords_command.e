note
	description: "Summary description for {ES_RESET_KEYWORDS_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_RESET_KEYWORDS_COMMAND

inherit
	ES_COMMAND_WITH_HELP

	SHARED_EXECUTION_ENVIRONMENT

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "Reset keywords from file(s)"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			u: ENVIRONMENT_PATH_UTILITIES
			p: PATH
			l_recursive: BOOLEAN
			l_targets: ARRAYED_LIST [READABLE_STRING_32]
			args: LIST [READABLE_STRING_32]
			ut: FILE_UTILITIES
			l_extension, l_arg: READABLE_STRING_32
			l_verbose, l_simulation: BOOLEAN
		do
			create u
			args := ctx.arguments
			create l_targets.make (args.count)
			from
				args.start
			until
				args.after
			loop
				l_arg := args.item
				if l_arg.starts_with ("-") then
					if l_arg.is_case_insensitive_equal ("-r") or l_arg.is_case_insensitive_equal ("--recursive") then
						l_recursive := True
					elseif l_arg.is_case_insensitive_equal ("-s") or l_arg.is_case_insensitive_equal ("--simulation") then
						l_simulation := True
					elseif l_arg.is_case_insensitive_equal ("-v") or l_arg.is_case_insensitive_equal ("--verbose") then
						l_verbose := True
					elseif l_arg.is_case_insensitive_equal ("-e") or l_arg.is_case_insensitive_equal ("--extension") then
						args.forth
						if args.after then
							printer.localized_print_error ({STRING_32} "Warning: missing value for %"-e|--extension" + {STRING_32} "%" option.")
						else
							l_extension := args.item
						end
					else
						printer.localized_print_error ({STRING_32} "Warning: %""+ l_arg + {STRING_32} "%" ignored.")
					end
				else
					l_targets.force (l_arg)
				end
				args.forth
			end

			across
				l_targets as c
			loop
				create p.make_from_string (c.item)
				reset_keywords_on_entry (p, l_recursive, l_simulation, l_extension, l_verbose)
			end
		end

	reset_keywords_on_entry (p: PATH; is_recursive: BOOLEAN; is_simulation: BOOLEAN; ext: detachable READABLE_STRING_GENERAL; is_verbose: BOOLEAN)
		local
			ut: FILE_UTILITIES
		do
			if ut.file_path_exists (p) then
				if ext /= Void then
					if attached p.extension as e and then ext.same_string (e) then
						reset_keywords_on_file (p, is_simulation, is_verbose)
					else
						-- Skipped
						if is_verbose then
							printer.localized_print ("Skipped entry %"")
							printer.localized_print (p.name)
							printer.localized_print ("%": not expected extension ")
							printer.localized_print (ext)
							printer.localized_print ("!%N")
						end
					end
				else
					reset_keywords_on_file (p, is_simulation, is_verbose)
				end
			elseif ut.directory_path_exists (p) then
				if is_recursive then
					reset_keywords_on_folder (p, is_simulation, ext, is_verbose)
				end
			else
				-- Skipped
				if is_verbose then
					printer.localized_print ("Skipped entry %"")
					printer.localized_print (p.name)
					printer.localized_print ("%"!%N")
				end
			end
		end

	reset_keywords_on_folder (a_location: PATH; is_simulation: BOOLEAN; ext: detachable READABLE_STRING_GENERAL; is_verbose: BOOLEAN)
		local
			d: DIRECTORY
			p: PATH
			ut: FILE_UTILITIES
		do
			create d.make_with_path (a_location)
			if d.exists and then d.is_readable then
				across
					d.entries as ic
				loop
					p := ic.item
					if p.is_parent_symbol or p.is_current_symbol then
					else
						reset_keywords_on_entry (a_location.extended_path (p), True, is_simulation, ext, is_verbose)
					end
				end
			end
		end

	reset_keywords_on_file (p: PATH; is_simulation: BOOLEAN; is_verbose: BOOLEAN)
			-- Reset values in manifest string like `"$date=....$"` to `"$date$"`.
		local
			f: RAW_FILE
			s: STRING
			l_line: STRING
			i,pos,colpos,endpos: INTEGER
			n : INTEGER
			lst: ARRAYED_LIST [READABLE_STRING_8]
		do
			create f.make_with_path (p)
			if f.exists and then f.is_access_readable and then f.is_access_writable then
				create lst.make (0)
				create s.make (f.count)
				f.open_read
				from
				until
					f.exhausted or f.end_of_file
				loop
					f.read_line
					l_line := f.last_string
					i := 1
					from
					until
						i = 0
					loop
						pos := l_line.substring_index ("%"$", i)
						colpos := l_line.index_of (':', pos + 2)
						endpos := l_line.substring_index ("$%"", pos + 2)
						if colpos > i and endpos > colpos then
							n := l_line.count
							lst.force (l_line.substring (pos + 2, colpos - 1))
							l_line.replace_substring ("%"$" + l_line.substring (pos + 2, colpos - 1) + "$%"", pos.max (1), endpos + 1)
							i := endpos + 1 - (n - l_line.count) + 1 -- substract the diff
						else
							i := 0
						end
					end
					s.append (l_line)
					if not f.end_of_file then
						s.append_character ('%N')
					end
				end
				f.close
				if lst.count > 0 then
					printer.localized_print ("Keywords: [ ")
					across
						lst as ic
					loop
						printer.localized_print (ic.item)
						printer.localized_print (" ")
					end
					printer.localized_print ("] in file %"")
					printer.localized_print (p.name)
					printer.localized_print ("%"")
					if is_simulation then
						printer.localized_print (" SIMULATED.%N")
					else
						f.open_write
						f.put_string (s)
						f.close
						printer.localized_print (" SAVED.%N")
					end
				end
			else
				if is_verbose then
					printer.localized_print ("Skipped file %"")
					printer.localized_print (p.name)
					printer.localized_print ("%"!%N")
				end
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			printer.localized_print ("Reset keywords from file(s)")
		end

end
