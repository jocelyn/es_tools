note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ES_SETUP_COMMAND

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
			Result := "EiffelStudio setup utilities"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			layout: ES_EIFFEL_LAYOUT
			v_name: STRING
--			l_choices: STRING_TABLE [TUPLE [product_version_name: STRING; version_name: STRING; is_current_version: BOOLEAN]] -- Index by choice index
		do
			create layout
			set_eiffel_layout (layout)

			v_name := layout.version_name
			across
				layout.installed_version_names as ic
			loop
				if v_name.is_case_insensitive_equal_general (ic.item) then
					printer.localized_print ("Current version:")
					display_version_info (layout, ic.item.as_string_32)
				else
					printer.localized_print ("<Previous>")
					display_version_info (layout, ic.item.as_string_32)
				end
			end
			io.put_new_line
		end

	migrate_from (a_version_name: STRING)
		local
		do

		end

	display_version_info (a_layout: ES_EIFFEL_LAYOUT; a_version_name: READABLE_STRING_GENERAL)
		do
			printer.localized_print ({STRING_32} "[" + a_version_name + "] ")
			print ("%N")
			if attached a_layout.eiffel_preferences_for_version (a_version_name, False) as l_pref_loc then
				print ("  - Prefs: ")
				printer.localized_print (l_pref_loc)
				print ("%N")
			end
			if attached a_layout.user_files_path_for_version (a_version_name, False) as l_user_files_loc then
				print ("  - Files: ")
				printer.localized_print (l_user_files_loc.name)
				print ("%N")
			end
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
