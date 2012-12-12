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
		do
			if a_context.logo_enabled then
				io.put_string ("-- ")
				printer.localized_print (manager.logo)
				io.put_new_line
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
			if n /= Void and cmd /= Void then
				display_short_help (cmd, n)
				io.put_new_line
				cmd.execute (ctx)
			else
				execute_help
			end
		end

	execute_help
		do
			across
				manager as c
			loop
				if attached {ES_PATH_GROUP_COMMAND} c.item as m then
					io.put_string ("+ ")
					display_short_help (m, c.key)
				end
			end
			across
				manager as c
			loop
				if not attached {ES_PATH_GROUP_COMMAND} c.item then
					display_short_help (c.item, c.key)
				end
			end
		end

	display_short_help (cmd: ES_COMMAND; a_name: READABLE_STRING_GENERAL)
		do
			printer.localized_print (a_name)
			if attached cmd.description as d then
				io.put_string (":%T")
				printer.localized_print (d)
			end
			io.put_new_line
		end

end
