note
	description: "Summary description for {ES_HELP_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_HELP_COMMAND

inherit
	ES_COMMAND

create
	make_with_manager

feature {NONE} -- Initialization

	make_with_manager (m: like manager)
		do
			manager := m
		end

	manager: ES_COMMAND_MANAGER

feature -- Status report

	is_available: BOOLEAN
		do
			Result := True
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		once
			Result := "help on command"
		end

feature -- Execution

	execute (a_context: ES_COMMAND_CONTEXT)
		local
			ctx: ES_COMMAND_CONTEXT
			n: detachable READABLE_STRING_GENERAL
			cmd: detachable ES_COMMAND
			args: ARGUMENTS_32
		do
			if a_context.logo_enabled then
				io.put_string ("-- ")
				printer.localized_print (manager.logo)
				io.put_new_line
				if a_context.is_verbose then
					create args
					printer.localized_print (args.argument (0))
					io.put_new_line
				end
				io.put_new_line
				ctx := a_context.without_logo
			else
				ctx := a_context
			end

			if ctx.arguments.count > 0 then
				n := ctx.arguments.first
				create ctx.make_from_string ("help")
				ctx := (create {ES_COMMAND_CONTEXT}.make_from_string ("help")).extended_context (ctx.without_first_argument)
				ctx.apply_settings_from (a_context)
				cmd := manager.command (n)
				if cmd /= Void and then not cmd.is_available then
					cmd := Void
				end
			end
			if n /= Void and then cmd /= Void and then cmd.is_available then
				display_short_help (cmd, n)
				io.put_new_line
				cmd.execute (ctx)
			else
				execute_help
			end
		end

	execute_help
		local
			n: INTEGER
		do
			n := 0

			across
				manager as c
			loop
				if c.item.is_available then
					n := n.max (c.key.count)
				end
			end

				-- Display commands
			across
				manager as c
			loop
				if
					c.item.is_available
				then
					if attached {ES_GROUP_COMMAND} c.item as grp then
--						io.put_string ("+ ")
						display_short_help (grp, string_adapted_to_width (c.key, n))

					else
						display_short_help (c.item, string_adapted_to_width (c.key, n))
					end
				end
			end
		end

	string_adapted_to_width (s: READABLE_STRING_GENERAL; n: INTEGER): STRING_32
		do
			from
				create Result.make_from_string_general (s)
			until
				Result.count >= n
			loop
				Result.append_character (' ')
			end
		end

	display_short_help (cmd: ES_COMMAND; a_name: READABLE_STRING_GENERAL)
		do
			io.put_string (" ")
			printer.localized_print (a_name)
			if attached cmd.description as d then
				io.put_string (" : ")
				printer.localized_print (d)
			end
			if attached {ES_GROUP_COMMAND} cmd as grp then
				if cmd.description = Void then
					io.put_string (" > ")
				end
				io.put_string (" ... ")
			end

			io.put_new_line
		end

end
