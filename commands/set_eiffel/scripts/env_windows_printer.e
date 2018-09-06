note
	description: "Summary description for {ENV_WINDOWS_PRINTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_WINDOWS_PRINTER

inherit
	ENV_VISITOR

create
	make

feature {NONE} -- Initialization

	make (a_buffer: STRING_32)
		do
			buffer := a_buffer
		end

feature -- Access

	buffer: STRING_32

feature -- Visit

	visit_script (a_script: ENV_SCRIPT)
		do
			visit_group (a_script)
		end

	visit_group (a_group: ENV_INSTRUCTION_GROUP)
		do
			across
				a_group as ic
			loop
				ic.item.accept (Current)
				buffer.append_character ('%N')
			end
		end

	visit_comment (a_value: ENV_SCRIPT_COMMENT)
		do
			across
				a_value.lines as ic
			loop
				buffer.append (":: ")
				buffer.append_string_general (ic.item)
				buffer.append_character ('%N')
			end
		end

	visit_call (a_value: ENV_CALL)
		do
			buffer.append ("call ")
			a_value.command.accept (Current)
			if attached a_value.arguments as args then
				across
					args as ic
				loop
					buffer.append_character (' ')
					ic.item.accept (Current)
				end
			end
			buffer.append_character ('%N')
		end

	visit_assignment (a_value: ENV_ASSIGNMENT)
		do
			buffer.append ("set ")
			buffer.append (a_value.name)
			buffer.append ("=")
			a_value.value.accept (Current)
			buffer.append_character ('%N')
		end

	visit_string (a_value: ENV_STRING_VALUE)
		do
			buffer.append (a_value.value)
		end

	visit_path (a_value: ENV_PATH_VALUE)
		local
			l_is_first: BOOLEAN
		do
			l_is_first := True
			across
				a_value.items as ic
			loop
				if l_is_first then
					l_is_first := False
					buffer.append_character (';')
				end
				ic.item.accept (Current)
			end
		end

	visit_variable (a_value: ENV_VARIABLE)
		do
			buffer.append_character ('%%')
			buffer.append (a_value.name)
			buffer.append_character ('%%')
		end

end
