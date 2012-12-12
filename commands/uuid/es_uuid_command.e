note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ES_UUID_COMMAND

inherit
	ES_COMMAND_WITH_HELP

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "UUID generator"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			g: UUID_GENERATOR
		do
			create g
			if attached g.generate_uuid as l_uuid then
				io.put_string (l_uuid.out)
				io.put_new_line
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			printer.localized_print ("Print a new UUID")
		end

end
