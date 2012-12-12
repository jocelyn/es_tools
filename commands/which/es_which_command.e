note
	description: "Summary description for {ES_WHICH_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_WHICH_COMMAND

inherit
	ES_COMMAND_WITH_HELP

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
			l_all: BOOLEAN
		do
			create u
			across
				ctx.arguments as c
			loop
				if c.item.starts_with ("-") then
					if c.item.is_case_insensitive_equal ("-a") or c.item.is_case_insensitive_equal ("--all") then
						l_all := True
					end
				else
					create p.make_from_string (c.item)
					if l_all then
						if attached u.list_of_path_containing_executable (p, 0) as lst_p then
							across
								lst_p as pc
							loop
								printer.localized_print (pc.item.name)
								io.put_new_line
							end
						end
					else
						if attached u.absolute_executable_path (p) as w_p then
							printer.localized_print (w_p.name)
							io.put_new_line
						end
					end
				end
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			printer.localized_print ("Return the location of executable(s)%N")
			printer.localized_print ("Usage: command [-a|--all] programnames%N")
			printer.localized_print ("%T-a or -all: to show all locations.%N")
		end

end
