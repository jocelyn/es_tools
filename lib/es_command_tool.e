note
	description: "Summary description for {ES_COMMAND_TOOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ES_COMMAND_TOOL

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		deferred
		end

feature -- Execution

	launch
		local
			ctx: ES_COMMAND_CONTEXT
		do
			if is_available then
				create ctx.make_from_arguments
				execute (ctx.without_first_argument)
			end
		end

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		require
			is_available: is_available
		deferred
		end

end
