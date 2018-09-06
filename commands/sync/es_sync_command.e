note
	description: "Summary description for {ES_SYNC_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_SYNC_COMMAND

inherit
	ES_COMMAND_WITH_HELP

	SHARED_EXECUTION_ENVIRONMENT

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "Synchronize two folder(s)"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			u: ENVIRONMENT_PATH_UTILITIES
			p: PATH
			args: LIST [READABLE_STRING_32]
			v: READABLE_STRING_32
			l_source, l_target: PATH
			l_sync_ctx: ES_SYNC_CONTEXT
		do
			create u

			args := ctx.arguments

			create l_sync_ctx
			l_sync_ctx.is_recursive := True

			from
				args.start
			until
				args.after
			loop
				v := args.item
				if v.starts_with ("-") then
					if v.is_case_insensitive_equal ("--source") then
						args.forth
						create l_source.make_from_string (args.item)
					elseif v.is_case_insensitive_equal ("--target") then
						args.forth
						create l_target.make_from_string (args.item)
					elseif v.is_case_insensitive_equal ("--extension") then
						args.forth
						l_sync_ctx.add_extension (args.item)
					elseif v.is_case_insensitive_equal ("--exclude") then
						args.forth
						l_sync_ctx.add_path_exclusion (args.item)
					elseif v.is_case_insensitive_equal ("--exclude-dir") then
						args.forth
						l_sync_ctx.add_directory_exclusion (args.item)
					elseif v.is_case_insensitive_equal ("--exclude-file") then
						args.forth
						l_sync_ctx.add_file_exclusion (args.item)
					elseif v.is_case_insensitive_equal ("--verbose") then
						l_sync_ctx.is_verbose := True
					elseif v.is_case_insensitive_equal ("--simulation") then
						l_sync_ctx.is_simulation := True

					elseif v.is_case_insensitive_equal ("--recursive") then
						l_sync_ctx.is_recursive := True
					elseif v.is_case_insensitive_equal ("--not-recursive") then
						l_sync_ctx.is_recursive := False
					else
						report_error ({STRING_32} "Warning: %""+ v + {STRING_32} "%" ignored.")
					end
				else
					report_error ({STRING_32} "Warning: %""+ v + {STRING_32} "%" ignored.")
				end
				args.forth
			end

			if l_source = Void then
				create l_source.make_current
			end
			if l_target = Void then
				create l_target.make_current
			end
			synchronize (l_source, l_target, l_sync_ctx)
		end

	report_warning (msg: READABLE_STRING_32)
		do
			localized_print_error (msg)
		end

	report_error (msg: READABLE_STRING_32)
		do
			localized_print_error (msg)
			(create {EXCEPTIONS}).die (-1)
		end

	synchronize (src,tgt: PATH; ctx: ES_SYNC_CONTEXT)
		local
			exec: ES_SYNC_COMMAND_EXECUTION
			d1, d2: DIRECTORY
		do
			create exec.make (ctx)
			create d1.make_with_path (src)
			create d2.make_with_path (tgt)
			exec.copy_directory (d1, d2)
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			localized_print ("Synchronize two folders%N")
			localized_print ("Usage: sync ... s%N")
			localized_print ("%T--source: source directory.%N")
			localized_print ("%T--target: target directory.%N")
			localized_print ("%T--extension ext: handle files with associated extension.%N")
			localized_print ("%T--exclude name-or-pattern: exclude file or directory based on name-or-pattern value.%N")
			localized_print ("%T--exclude-dir name-or-pattern: exclude directories matching name-or-pattern value.%N")
			localized_print ("%T--exclude-file name-or-pattern: exclude files matching name-or-pattern value.%N")
			localized_print ("%T--recursive: sync directory and sub directories recursively.%N")
			localized_print ("%T--simulation: do not change anything on file system.%N")
			localized_print ("%T--verbose: verbose output.%N")
		end

end
