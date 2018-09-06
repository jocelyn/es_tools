note
	description: "Summary description for {ES_WHICH_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_WHICH_COMMAND

inherit
	ES_COMMAND_WITH_HELP

	SHARED_EXECUTION_ENVIRONMENT

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "Return the location of executable(s)"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			u: ENVIRONMENT_PATH_UTILITIES
			p: PATH
			l_parent_action, l_all: BOOLEAN
			l_targets: ARRAYED_LIST [READABLE_STRING_32]
			args: LIST [READABLE_STRING_32]
		do
			create u

			args := ctx.arguments
			create l_targets.make (args.count)
			across
				args as c
			loop
				if c.item.starts_with ("-") then
					if c.item.is_case_insensitive_equal ("-a") or c.item.is_case_insensitive_equal ("--all") then
						l_all := True
					elseif c.item.is_case_insensitive_equal ("-p") or c.item.is_case_insensitive_equal ("--parent") then
						l_parent_action := True
					else
						localized_print_error ({STRING_32} "Warning: %""+ c.item + {STRING_32} "%" ignored.")
					end
				else
					l_targets.force (c.item)
				end
			end

			across
				l_targets as c
			loop
				create p.make_from_string (c.item)
				if l_all then
					if attached u.list_of_path_containing_executable (p, 0) as lst_p then
						across
							lst_p as pc
						loop
							if l_parent_action then
								localized_print (pc.item.parent.name)
							else
								localized_print (pc.item.name)
							end
							io.put_new_line
						end
					end
				else
					if attached u.absolute_executable_path (p) as w_p then
						if l_parent_action then
							localized_print (w_p.parent.name)
						else
							localized_print (w_p.name)
						end
						io.put_new_line
					end
				end
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			localized_print ("Return the location of executable(s)%N")
			localized_print ("Usage: command [-a|--all] programnames%N")
			localized_print ("%T-a or --all: to show all locations.%N")
			localized_print ("%T-p or --parent: to show the parent location.%N")
		end

end
