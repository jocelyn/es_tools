note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ES_LAYOUT_COMMAND

inherit
	ES_COMMAND_WITH_HELP

	SHARED_EXECUTION_ENVIRONMENT

	EIFFEL_LAYOUT

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "Information related to the Eiffel environment"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			layout: ES_EIFFEL_LAYOUT
		do
			create layout
			set_eiffel_layout (layout)

			printer.localized_print ("Eiffel variables:")
			io.put_new_line
			display_environ_variable ("ISE_EIFFEL")
			display_environ_variable ("ISE_LIBRARY")
			display_environ_variable ("ISE_PLATFORM")
			display_environ_variable ("ISE_C_COMPILER")
			display_environ_variable ("ISE_CFLAGS")
			display_environ_variable ("ISE_EC_FLAGS")
			display_environ_variable ("ISE_PROJECTS")
			io.put_new_line

			printer.localized_print ("Eiffel folders:")
			io.put_new_line
			printer.localized_print (" - Installation=")
			printer.localized_print (layout.install_path.name)
			io.put_new_line

			printer.localized_print (" - Configuration=")
			printer.localized_print (layout.config_path.name)
			io.put_new_line

			printer.localized_print (" - Binary=")
			printer.localized_print (layout.bin_path.name)
			io.put_new_line

			printer.localized_print (" - Hidden files=")
			printer.localized_print (layout.hidden_files_path.name)
			io.put_new_line

			printer.localized_print (" - User files=")
			printer.localized_print (layout.user_files_path.name)
			io.put_new_line

			printer.localized_print (" - User projects=")
			printer.localized_print (layout.user_projects_path.name)
			io.put_new_line

			printer.localized_print (" - User templates=")
			printer.localized_print (layout.user_templates_path.name)
			io.put_new_line

			io.put_new_line
		end

	display_environ_variable  (n: READABLE_STRING_GENERAL)
		do
			if attached execution_environment.item (n) as v then
				printer.localized_print (" - ")
				printer.localized_print (n)
				printer.localized_print ("=")
				printer.localized_print (v)
				io.put_new_line
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			printer.localized_print ("Help:  ...")
			io.put_new_line
		end

end
