note
	description: "Objects that ..."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	SHARED_EXECUTION_ENVIRONMENT

	ES_COMMAND_MANAGER_OBSERVER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			n: STRING
			arr: ARRAY [READABLE_STRING_32]
			p: detachable PATH
			ini_path: PATH
			i: INTEGER
			is_shell: BOOLEAN
			is_portable: BOOLEAN
			logo_enabled: BOOLEAN
			ctx: ES_COMMAND_CONTEXT
			l_config_path: detachable PATH
			l_es_tool_name: STRING_32
			l_config_name: STRING_32
		do
			is_verbose := False
			is_shell := False
			logo_enabled := True

			arr := execution_environment.arguments.argument_array.twin
			arr.rebase (1)
			if arr.count > 0 then
				from
					i := arr.lower + 1 -- skip command name
				until
					i > arr.upper or not arr[i].starts_with_general ("-")
				loop
					n := arr[i]
					check n.starts_with ("-") end
					if n.same_string ("-v") or n.same_string ("--verbose") then
						is_verbose := True
					elseif n.same_string ("-s") or n.same_string ("--shell") then
						is_shell := True
					elseif n.same_string ("--portable") then
						is_portable := True
					elseif n.same_string ("--no-logo") then
						logo_enabled := False
					elseif n.same_string ("--logo") then
						logo_enabled := True
					elseif n.same_string ("--config") then
						i := i + 1
						if arr.valid_index (i) then
							create l_config_path.make_from_string (arr[i])
						end
					end
					i := i + 1
				end
				arr := arr.subarray (i, arr.count)
				arr.rebase (1)
			end

			initialize

			is_empty_call := arr.is_empty

			create p.make_from_string (execution_environment.arguments.command_name) -- Get command name
			p := command_path (p)
			l_es_tool_name :=  command_name (p)

			if attached execution_environment.item (l_es_tool_name.as_upper + "_CONFIG_NAME") as v then
				l_config_name := v
			else
				l_config_name := {STRING_32} "." + l_es_tool_name + "-rc"
			end

			create ini_path.make_from_string (l_config_name)
			ini_path := ini_path.extended ({ES_TOOL_CONSTANTS}.es_ini_filename)

			if
				p /= Void and then
				p.is_absolute and then -- useless due to postcondition from command_path ..
				attached p.parent as l_parent
			then
				-- Install folder
				manager.import (l_parent.extended_path (ini_path))
			end

			if is_portable then
					-- Ignore Home folder
			else
				-- Platform specific Home folder
				if attached execution_environment.home_directory_path as h_path then
					manager.import (h_path.extended_path (ini_path))
				end
				-- $HOME folder
				if attached execution_environment.item ("home") as h_dir then
					manager.import ((create {PATH}.make_from_string (h_dir)).extended_path (ini_path))
				end
			end

			if l_config_path /= Void then
				manager.import (l_config_path)
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
			manager.observers.extend (Current)
		end

	help_command: ES_HELP_COMMAND

feature -- Status

	is_verbose: BOOLEAN

	is_empty_call: BOOLEAN

feature -- Event

	on_path_import (p: PATH)
		local
			f: RAW_FILE
		do
			if is_verbose and is_empty_call then
				create f.make_with_path (p)
				if f.exists then
					if f.is_access_readable then
						if f.is_directory then
							print ("Looking into")
						else
							print ("Loading")
						end
					else
						print ("Can not read")
					end
				else
					print ("Can not found")
				end
				print (" %"")
				print (p.name)
				print ("%"")
				print ("%N")
			end
		end

feature -- Access

	manager: ES_COMMAND_MANAGER

feature {NONE} -- Implementation

	command_path (a_path: PATH): PATH
		do
			Result := a_path.absolute_path.canonical_path
		ensure
			Result /= Void implies Result.is_absolute
		end

	command_name (a_path: PATH): STRING_32
		local
--			u: ENVIRONMENT_PATH_UTILITIES
			p: PATH
		do
			if attached a_path.entry as e then
				p := e
			else
				p := a_path
			end
			Result := p.name
			if attached p.extension as ext then
				Result.remove_tail (ext.count + 1)
			end
		ensure
			Result /= Void
		end

invariant

end
