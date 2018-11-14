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

feature -- Helper

	is_valid_keyword (k: READABLE_STRING_8): BOOLEAN
		local
			i,n: INTEGER
			c: CHARACTER_8
		do
			Result := True
			from
				i := 1
				n := k.count
			until
				i > n or not Result
			loop
				c := k [i]
				if c.is_alpha_numeric or c = '-' or c = '_' then
						-- Alphanumeric, , - or _ (to be flexible)
				else
					Result := False
				end
				i := i + 1
			end
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
			l_arg: READABLE_STRING_32
			l_extensions, l_keywords: detachable ARRAYED_LIST [READABLE_STRING_32]
			l_verbose, l_simulation: BOOLEAN
			cmd_ctx: ES_RESET_KEYWORDS_CONTEXT
		do
			args := ctx.arguments
			if args.is_empty then
				execute_help (ctx)
			else
				create u
				create l_targets.make (args.count)

				create cmd_ctx
--				cmd_ctx.is_recursive := True

				from
					args.start
				until
					args.after
				loop
					l_arg := args.item
					if l_arg.starts_with ("-") then
						if l_arg.is_case_insensitive_equal ("-r") or l_arg.is_case_insensitive_equal ("--recursive") then
							cmd_ctx.is_recursive := True
						elseif l_arg.is_case_insensitive_equal ("--not-recursive") then
							cmd_ctx.is_recursive := False
						elseif l_arg.is_case_insensitive_equal ("-s") or l_arg.is_case_insensitive_equal ("--simulation") then
							cmd_ctx.is_simulation := True
						elseif l_arg.is_case_insensitive_equal ("-v") or l_arg.is_case_insensitive_equal ("--verbose") then
							cmd_ctx.is_verbose := True
						elseif l_arg.is_case_insensitive_equal ("-e") or l_arg.is_case_insensitive_equal ("--extension") then
							args.forth
							if args.after then
								localized_print_error ({STRING_32} "Warning: missing value for %"-e|--extension" + {STRING_32} "%" option.")
							else
								cmd_ctx.add_extension (args.item)
							end
						elseif l_arg.is_case_insensitive_equal ("--exclude") then
							args.forth
							if args.after then
								localized_print_error ({STRING_32} "Warning: missing value for %"--exclude" + {STRING_32} "%" option.")
							else
								cmd_ctx.add_path_exclusion (args.item)
							end
						elseif l_arg.is_case_insensitive_equal ("--exclude-dir") then
							args.forth
							if args.after then
								localized_print_error ({STRING_32} "Warning: missing value for %"--exclude-dir" + {STRING_32} "%" option.")
							else
								cmd_ctx.add_directory_exclusion (args.item)
							end
						elseif l_arg.is_case_insensitive_equal ("--exclude-file") then
							args.forth
							if args.after then
								localized_print_error ({STRING_32} "Warning: missing value for %"--exclude-file" + {STRING_32} "%" option.")
							else
								cmd_ctx.add_file_exclusion (args.item)
							end
						elseif l_arg.is_case_insensitive_equal ("-k") or l_arg.is_case_insensitive_equal ("--keyword") then
							args.forth
							if args.after then
								localized_print_error ({STRING_32} "Warning: missing value for %"-k|--keyword" + {STRING_32} "%" option.")
							else
								cmd_ctx.add_keyword (args.item)
							end
						else
							localized_print_error ({STRING_32} "Warning: %""+ l_arg + {STRING_32} "%" ignored.")
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
					reset_keywords_on_entry (p, False, cmd_ctx)
				end
			end
		end

	reset_keywords_on_entry (p: PATH; a_force_recursive: BOOLEAN; ctx: ES_RESET_KEYWORDS_CONTEXT)
		local
			ut: FILE_UTILITIES
			exec: ES_RESET_KEYWORDS_COMMAND_EXECUTION
		do
			if ut.file_path_exists (p) then
				if attached p.entry as l_entry then
					create exec.make (ctx)
					if exec.file_excluded (l_entry, p.parent) then
						-- Skipped
						if ctx.is_verbose then
							localized_print ("Skipped entry %"")
							localized_print (p.name)
							localized_print ("%"!%N")
						end
					else
						reset_keywords_on_file (p, ctx)
					end
				else
					check False end
				end
			elseif ut.directory_path_exists (p) then
				create exec.make (ctx)
				if ctx.is_verbose then
					exec.process (p, agent reset_keywords_on_file (?, ctx), agent (i_p: PATH)
							do
								localized_print ("Skipped entry %"")
								localized_print (i_p.name)
								localized_print ("%"!%N")
							end)
				else
					exec.process (p, agent reset_keywords_on_file (?, ctx), Void)
				end
			else
				-- Skipped
				if ctx.is_verbose then
					localized_print ("Skipped entry %"")
					localized_print (p.name)
					localized_print ("%"!%N")
				end
			end
--			if ut.file_path_exists (p) then
--				if attached ctx.included_extensions as l_extensions then
--					if attached p.extension as e and then across l_extensions as ic some ic.item.same_string (e) end then
--						reset_keywords_on_file (p, ctx)
--					else
--						-- Skipped
--						if ctx.is_verbose then
--							localized_print ("Skipped entry %"")
--							localized_print (p.name)
--							localized_print ("%": not expected extension (")
--							across
--								l_extensions as ic
--							loop
--								localized_print (" ")
--								localized_print (ic.item)
--							end
--							localized_print (" )!%N")
--						end
--					end
--				else
--					reset_keywords_on_file (p,  ctx)
--				end
--			elseif ut.directory_path_exists (p) then
--				if a_force_recursive or ctx.is_recursive then
--					reset_keywords_on_folder (p, ctx)
--				end
--			else
--				-- Skipped
--				if ctx.is_verbose then
--					localized_print ("Skipped entry %"")
--					localized_print (p.name)
--					localized_print ("%"!%N")
--				end
--			end
		end

	reset_keywords_on_folder (a_location: PATH; ctx: ES_RESET_KEYWORDS_CONTEXT)
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
						reset_keywords_on_entry (a_location.extended_path (p), True, ctx)
					end
				end
			end
		end

	reset_keywords_on_file (p: PATH; ctx: ES_RESET_KEYWORDS_CONTEXT)
			-- Reset values in manifest string like `"$date=....$"` to `"$date$"`.
		local
			f: RAW_FILE
			s: STRING
			l_line: STRING
			i,pos,colpos,endpos: INTEGER
			n : INTEGER
			lst: ARRAYED_LIST [READABLE_STRING_8]
			l_keyword: READABLE_STRING_8
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
							l_keyword := l_line.substring (pos + 2, colpos - 1)
							if is_valid_keyword (l_keyword) then
								if
									attached ctx.keywords as l_keywords and then
									not across l_keywords as ic some ic.item.same_string (l_keyword) end
								then
										-- Not expected keyword... skip
									i := colpos
								else
									lst.force (l_keyword)
									l_line.replace_substring ("%"$" + l_keyword + "$%"", pos.max (1), endpos + 1)
									i := endpos + 1 - (n - l_line.count) + 1 -- substract the diff
								end
							end
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
					localized_print ("Keywords: [ ")
					across
						lst as ic
					loop
						localized_print (ic.item)
						localized_print (" ")
					end
					localized_print ("] in file %"")
					localized_print (p.name)
					localized_print ("%"")
					if ctx.is_simulation then
						localized_print (" SIMULATED.%N")
					else
						f.open_write
						f.put_string (s)
						f.close
						localized_print (" SAVED.%N")
					end
				end
			else
				if ctx.is_verbose then
					localized_print ("Skipped file %"")
					localized_print (p.name)
					localized_print ("%"!%N")
				end
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			localized_print ("Reset keywords from file(s)%N")
			localized_print ("Usage: prog  ...%N")
			localized_print ("  -e|--extension              : process only file with such extension (multiple accepted)%N")
			localized_print ("  -k|--keyword                : process only keyword with such name (multiple accepted)%N")
			localized_print ("  -r|--recursive              : process subfolder recursively%N")
			localized_print ("  --exclude pattern           : exclude path (directory or file)%N")
			localized_print ("  --exclude-directory pattern : exclude directory%N")
			localized_print ("  --exclude-file pattern      : exclude filename%N")
			localized_print ("  -s|--simulation             : simulating without any change on file%N")
			localized_print ("  -v|--verbose                : display verbose output%N")
		end

end
