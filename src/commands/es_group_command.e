note
	description: "Summary description for {ES_GROUP_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_GROUP_COMMAND

inherit
	ES_COMMAND

	SHARED_EXECUTION_ENVIRONMENT

create
	make,
	make_with_manager

feature {NONE} -- Initialization

	make
		do
			make_with_manager (create {like manager}.make)
		end

	make_with_manager (m: like manager)
		do
			manager := m
		end

	manager: ES_COMMAND_MANAGER

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		do
			Result := not manager.is_empty
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32

feature -- Change

	set_description (d: like description)
		do
			description := d
		end

	register (cmd: ES_COMMAND; a_name: READABLE_STRING_GENERAL)
		do
			manager.register (cmd, a_name)
		end

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		local
			l_done: BOOLEAN
		do
			if not ctx.is_empty then
				if
					attached manager.command (ctx.arguments.first) as cmd and then
					cmd.is_available
				then
					l_done := True
					ctx.set_command_name (ctx.arguments.first)
					cmd.execute (ctx.without_first_argument)
				else
					localized_print_error ({STRING_32} "[ERROR] Invalid command: " + ctx.arguments.first + "!%N%N")
				end
			end
			if not l_done then
				if ctx.is_shell then
					(create {ES_MENU_COMMAND}.make_with_manager (manager)).execute (ctx)
				else
					(create {ES_HELP_COMMAND}.make_with_manager (manager)).execute (ctx)
				end
			end
		end

end
