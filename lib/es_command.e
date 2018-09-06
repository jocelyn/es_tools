note
	description: "Summary description for {ES_COMMAND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ES_COMMAND

inherit
	DEBUG_OUTPUT

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		deferred
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		deferred
		end

feature -- Status report

	debug_output: STRING_32
			-- String that should be displayed in debugger to represent `Current'.
		do
			create Result.make (0)
			if attached description as desc then
				Result.append (desc)
			end
		end

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		require
			is_available: is_available
		deferred
		end

feature -- Helper

	localized_printer: LOCALIZED_PRINTER
		once
			create Result
		end

	localized_print (s: detachable READABLE_STRING_GENERAL)
			-- Print `a_str` as localized encoding.
			-- `a_str` is taken as a UTF-32 string.
		do
			localized_printer.localized_print (s)
		end

	localized_print_error (s: detachable READABLE_STRING_GENERAL)
			-- Print an error, `a_str`, as localized encoding.
			-- `a_str` is taken as a UTF-32 string.
		do
			localized_printer.localized_print_error (s)
		end

end
