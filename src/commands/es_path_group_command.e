note
	description: "Summary description for {ES_PATH_GROUP_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_PATH_GROUP_COMMAND

inherit
	ES_COMMAND

	LOCALIZED_PRINTER

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make (a_path: PATH)
		do
			path := a_path
		end

	path: PATH

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		local
			d: DIRECTORY
		do
			create d.make_with_path (path)
			Result := d.exists and then d.is_readable
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32

feature -- Change

	set_path (p: PATH)
		do
			path := p
		end

	set_description (d: like description)
		do
			description := d
		end

feature -- Execution

	execute (ctx: ES_COMMAND_CONTEXT)
		local
			manager: ES_COMMAND_MANAGER
		do
			create manager.make
			manager.import_all_from (path)

			if manager.is_empty then
				printer.localized_print (path.name)
				io.put_new_line
				if ctx.is_verbose then
					printer.localized_print ({STRING_32} "Executing " + path.name + "%N")
				end
			else
				if ctx.is_shell then
					(create {ES_MENU_COMMAND}.make_with_manager (manager)).execute (ctx)
				else
					(create {ES_HELP_COMMAND}.make_with_manager (manager)).execute (ctx)
				end
			end
		end

end
