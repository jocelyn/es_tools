note
	description: "Summary description for {ES_COMMAND_WITH_HELP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ES_COMMAND_WITH_HELP

inherit
	ES_COMMAND

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		do
			if ctx.is_first_argument_string ("help") then
				execute_help (ctx.without_first_argument)
			else
				execute_command (ctx)
			end
		end

	execute_command (ctx: ES_COMMAND_CONTEXT)
		require
			is_available: is_available
		deferred
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		require
			is_available: is_available
		deferred
		end

end
