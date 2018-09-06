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
			layout: ES_EIFFEL_VERSIONED_LAYOUT
			is_verbose: BOOLEAN
		do
			is_verbose := ctx.is_verbose
			if across ctx.arguments as ic some ic.item.same_string_general ("-v") end then
				is_verbose := True
			end

			if attached execution_environment.item ("ES_EIFFEL_VERSION") as v and then v.is_valid_as_string_8 then
				create layout.make_with_version (v.to_string_8)
			else
				create layout
			end
			set_eiffel_layout (layout)

			localized_print ("Eiffel variables:")
			io.put_new_line
			across
				<<
					"ISE_EIFFEL",
					"ISE_LIBRARY", "EIFFEL_LIBRARY",
					"ISE_PLATFORM",
					"ISE_C_COMPILER", "ISE_C_COMPILER_VER", "ISE_CFLAGS",
					"ISE_EC_FLAGS",
					"ISE_PROJECTS",
					"ISE_USER_FILES",
					"ISE_APP_DATA",
					"EC_NAME",
					"ISE_IRON_PATH",
					"IRON_PATH"
				>> as ic
			loop
				display_environ_variable (ic.item, is_verbose)
			end

			io.put_new_line

			localized_print ("Eiffel folders:")
			io.put_new_line
			localized_print (" - Installation=")
			localized_print (layout.install_path.name)
			io.put_new_line

			localized_print (" - Configuration=")
			localized_print (layout.config_path.name)
			io.put_new_line

			localized_print (" - Binary=")
			localized_print (layout.bin_path.name)
			io.put_new_line

			localized_print (" - Hidden files=")
			localized_print (layout.hidden_files_path.name)
			io.put_new_line

			localized_print (" - User files=")
			localized_print (layout.user_files_path.name)
			io.put_new_line

			localized_print (" - User projects=")
			localized_print (layout.user_projects_path.name)
			io.put_new_line

			localized_print (" - User templates=")
			localized_print (layout.user_templates_path.name)
			io.put_new_line

			io.put_new_line
		end

	display_environ_variable  (n: READABLE_STRING_GENERAL; is_verbose: BOOLEAN)
		do
			if attached execution_environment.item (n) as v then
				localized_print (" - ")
				localized_print (n)
				localized_print ("=")
				localized_print (v)
				io.put_new_line
			elseif is_verbose then
				localized_print (" - ")
				localized_print (n)
				localized_print (" is not set!")
				io.put_new_line
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			localized_print ("Help:  ...")
			io.put_new_line
		end

end
