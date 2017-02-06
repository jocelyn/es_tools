note
	description: "Summary description for {ES_COMMAND_CONTEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_COMMAND_CONTEXT

create
	make_empty,
	make_from_string,
	make_from_arguments,
	make_from_context

feature {NONE} -- Initialization

	make_empty
		do
			create {ARRAYED_LIST [STRING_32]} arguments.make (0)
		end

	make_from_string (s: READABLE_STRING_GENERAL)
		do
			make_empty
			extend_argument (s)
		end

	make_from_arguments
		local
			args: ARGUMENTS_32
		do
			make_empty
			create args
			across
				args.argument_array as c
			loop
				extend_argument (c.item)
			end
		end

	make_from_context (ctx: ES_COMMAND_CONTEXT)
		do
			make_empty
			across
				ctx.arguments as c
			loop
				extend_argument (c.item)
			end
			apply_settings_from (ctx)
		end

feature -- Access

	arguments: LIST [READABLE_STRING_32]

	is_empty: BOOLEAN
		do
			Result := arguments.is_empty
		end

	command_name: detachable READABLE_STRING_32
			-- Name used to invoke command.

feature -- Settings

	is_verbose: BOOLEAN

	is_shell: BOOLEAN

	logo_enabled: BOOLEAN

feature -- Status report

	is_first_argument_string (n: READABLE_STRING_GENERAL): BOOLEAN
		do
			if not arguments.is_empty then
				Result := arguments.first.same_string_general (n)
			end
		end

feature -- Factory

	extended_context (ctx: ES_COMMAND_CONTEXT): ES_COMMAND_CONTEXT
		do
			Result := extended_arguments (ctx.arguments)
		end

	extended_arguments (args: ITERABLE [READABLE_STRING_GENERAL]): ES_COMMAND_CONTEXT
		do
			create Result.make_from_context (Current)
			across
				args as c
			loop
				Result.extend_argument (c.item)
			end
		end

	extended_argument (s: READABLE_STRING_GENERAL): ES_COMMAND_CONTEXT
		do
			create Result.make_from_context (Current)
			Result.extend_argument (s)
		end

	without_first_argument: ES_COMMAND_CONTEXT
		do
			create Result.make_from_context (Current)
			Result.remove_first_argument
		end

	without_logo: ES_COMMAND_CONTEXT
		do
			create Result.make_from_context (Current)
			Result.set_logo_enabled (False)
		end

feature -- Settings change

	set_is_verbose (b: BOOLEAN)
		do
			is_verbose := b
		end

	set_is_shell (b: BOOLEAN)
		do
			is_shell := b
		end

	set_logo_enabled (b: BOOLEAN)
		do
			logo_enabled := b
		end

	apply_settings_from (ctx: ES_COMMAND_CONTEXT)
		do
			set_is_verbose (ctx.is_verbose)
			set_is_shell (ctx.is_shell)
			set_logo_enabled (ctx.logo_enabled)
		end

	set_command_name (a_name: like command_name)
		do
			command_name := a_name
		end

feature {ES_COMMAND_CONTEXT} -- Change

	extend_argument (s: READABLE_STRING_GENERAL)
		do
			arguments.extend (s.to_string_32)
		end

	remove_first_argument
		do
			arguments.start
			arguments.remove
		end



end
