note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ES_UUID_COMMAND

inherit
	ES_COMMAND_WITH_HELP

create
	default_create,
	make_lowercase,
	make_uppercase

feature {NONE} -- Initialization

	make_lowercase
		do
			is_uppercase := False
		end

	make_uppercase
		do
			is_uppercase := True
		end

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Settings

	is_uppercase: BOOLEAN
			-- Output UUID as uppercase?

	is_lowercase: BOOLEAN
			-- Output UUID as lowercase?
			-- Yes by default.
		do
			Result := not is_uppercase
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			if is_lowercase then
				Result := "Generate (lowercase) UUID"
			else
				Result := "Generate (uppercase) UUID"
			end
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			g: UUID_GENERATOR
			l_is_up: BOOLEAN
		do
			if attached ctx.command_name as l_cmd_name then
				l_is_up := l_cmd_name.same_string (l_cmd_name.as_upper)
			else
				l_is_up := is_uppercase
			end
			across
				ctx.arguments as ic
			loop
				if ic.item.same_string ("--lower") then
					l_is_up := False
				elseif ic.item.same_string ("--upper") then
					l_is_up := True
				end
			end

			create g
			if attached g.generate_uuid as l_uuid then
				if l_is_up then
					io.put_string (l_uuid.out)
				else
					io.put_string (l_uuid.out.as_lower)
				end
				io.put_new_line
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			if is_uppercase then
				printer.localized_print ("Print a new UUID in uppercase")
			else
				printer.localized_print ("Print a new UUID in lowercase")
			end
		end

end
