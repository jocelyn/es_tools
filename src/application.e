note
	description: "Objects that ..."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			args: ARGUMENTS
			n: STRING
			arr: ARRAY [STRING]
			p: detachable PATH
			ini_path: PATH
			i: INTEGER
			eiffel_version: detachable STRING_32
			is_verbose: BOOLEAN
			is_shell: BOOLEAN
			logo_enabled: BOOLEAN
			ctx: ES_COMMAND_CONTEXT
			cmd: detachable ES_COMMAND
		do
			initialize
			create args

			create ini_path.make_from_string ({ES_TOOL_CONSTANTS}.es_config_folder)
			ini_path := ini_path.extended ({ES_TOOL_CONSTANTS}.es_ini_filename)

			create p.make_from_string (args.command_name) -- Get command name
			p := command_path (p)

			is_verbose := False
			is_shell := False
			logo_enabled := True

			arr := args.argument_array.twin
			arr.rebase (1)
			if arr.count > 0 then
				from
					i := arr.lower + 1 -- skip command name
				until
					i > arr.upper or not arr[i].starts_with_general ("-")
				loop
					n := arr[i]
					check n.starts_with ("-") end
					if n.same_string ("--eiffel") and i < arr.upper then
						i := i + 1
						eiffel_version := arr[i]
					elseif n.same_string ("-v") or n.same_string ("--verbose") then
						is_verbose := True
					elseif n.same_string ("-s") or n.same_string ("--shell") then
						is_shell := True
					elseif n.same_string ("--no-logo") then
						logo_enabled := False
					end
					i := i + 1
				end
				arr := arr.subarray (i, arr.count)
				arr.rebase (1)
			end
			if eiffel_version /= Void then
				execution_environment.put (eiffel_version, "ES_EIFFEL_VERSION")
			else
				execution_environment.put ("", "ES_EIFFEL_VERSION")
			end

			if
				p /= Void and then
				p.is_absolute and then -- useless due to postcondition from command_path ..
				attached p.parent as l_parent
			then
				-- Install folder
				manager.import (l_parent.extended_path (ini_path))
			end

			-- Home folder
			if attached execution_environment.home_directory_path as h_path then
				manager.import (h_path.extended_path (ini_path))
			end
			-- $HOME folder
			if attached execution_environment.get ("home") as h_dir then
				manager.import ((create {PATH}.make_from_string (h_dir)).extended_path (ini_path))
			end

			-- Execution
			create ctx.make_empty
			ctx.set_is_verbose (is_verbose)
			ctx.set_is_shell (is_shell)
			ctx.set_logo_enabled (logo_enabled)
			if not arr.is_empty then
				ctx := ctx.extended_arguments (arr)
			end
			(create {ES_GROUP_COMMAND}.make_with_manager (manager)).execute (ctx)
		end

	initialize
		do
			initialize_commands
		end

	initialize_commands
		do
			create manager.make
			create help_command.make_with_manager (manager)
			manager.register (help_command, "help")
			manager.register (create {ES_LAYOUT_COMMAND}, "layout")
			manager.register (create {ES_UUID_COMMAND}, "uuid")
		end

	help_command: ES_HELP_COMMAND

feature -- Status

feature -- Access

	manager: ES_COMMAND_MANAGER

feature {NONE} -- Implementation

	command_path (a_path: PATH): detachable PATH
		local
			u: ENVIRONMENT_PATH_UTILITIES
		do
			create u
			Result := u.absolute_executable_path (a_path)
		ensure
			Result /= Void implies Result.is_absolute
		end

invariant

end
