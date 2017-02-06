note
	description: "Summary description for {ES_MENU_COMMAND}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_MENU_COMMAND

inherit
	ES_COMMAND

	LOCALIZED_PRINTER

	SHARED_EXECUTION_ENVIRONMENT

create
	make_with_manager

feature {NONE} -- Initialization

	make_with_manager (m: like manager)
		do
			manager := m
		end

	manager: ES_COMMAND_MANAGER

feature -- Status report

	is_available: BOOLEAN
			-- Is current command available?
		do
			Result := not manager.is_empty
		end

feature -- Access

	description: detachable IMMUTABLE_STRING_32

feature -- Change

	set_manager (m: like manager)
		do
			manager := m
		end

	set_description (d: like description)
		do
			description := d
		end

feature -- Execution

	execute (a_context: ES_COMMAND_CONTEXT)
		local
			ctx: ES_COMMAND_CONTEXT
			choices: HASH_TABLE [TUPLE [cmd: ES_COMMAND; name: READABLE_STRING_GENERAL] , INTEGER]
			i: INTEGER
			cmd: detachable ES_COMMAND
			quit: BOOLEAN
			l_help: BOOLEAN
			s: STRING
		do
			if a_context.logo_enabled then
				io.put_string ("-- ")
				printer.localized_print (manager.logo)
				io.put_new_line
				io.put_new_line
				ctx := a_context.without_logo
			else
				ctx := a_context
			end

			if
				not ctx.is_empty and then
				attached manager.command (ctx.arguments.first) as l_cmd
			then
				l_cmd.execute (ctx.without_first_argument)
			else
				create choices.make (3)
				i := 0

				across
					manager as c
				loop
					if attached {ES_PATH_GROUP_COMMAND} c.item as m then
						i := i + 1
						choices.force ([c.item, c.key], i)
					end
				end
				across
					manager as c
				loop
					if not attached {ES_PATH_GROUP_COMMAND} c.item as m then
						i := i + 1
						choices.force ([c.item, c.key], i)
					end
				end
				if choices.is_empty then
				else
					from
						quit := False
						l_help := True
						cmd := Void
					until
						cmd /= Void or quit
					loop
						if l_help then
							across
								choices as c
							loop
								io.put_string ("[" + c.key.out + "] ")
								localized_print (c.item.name)
								if attached {ES_PATH_GROUP_COMMAND} c.item.cmd as m then
									localized_print (" ...")
								end
								io.put_new_line
							end
							io.put_new_line
							localized_print ("[h] help%N")
							localized_print ("[q] quit menu%N")
							l_help := False
						end
						localized_print ("Enter your choice >")
						io.read_line
						s := io.last_string
						s.left_adjust
						s.right_adjust
						if s.is_integer then
							if attached choices.item (s.to_integer) as tu then
								cmd := tu.cmd
							end
						elseif s.is_case_insensitive_equal ("h") then
							l_help := True
						elseif s.is_case_insensitive_equal ("q") then
							quit := True
						elseif s.is_empty then
--							l_help := True
						else
							localized_print ("Choice invalid ...%N")
						end
					end
					if cmd /= Void then
						cmd.execute (ctx)
					end
				end
			end
		end

end
