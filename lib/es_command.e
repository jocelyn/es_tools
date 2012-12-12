note
	description: "Summary description for {ES_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ES_COMMAND

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		deferred
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		deferred
		end

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		require
			is_available: is_available
		deferred
		end

feature -- Helper

	printer: LOCALIZED_PRINTER
		once
			create Result
		end

end
