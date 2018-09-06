note
	description: "Summary description for {SET_EIFFEL_SCRIPT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_SCRIPT

inherit
	ENV_INSTRUCTION_GROUP

create
	make

feature -- Change

	add_comment (a_comments: READABLE_STRING_GENERAL)
		do
			items.force (create {ENV_SCRIPT_COMMENT}.make (a_comments))
		end

	assign_variable (a_var_name: READABLE_STRING_GENERAL; a_value: ENV_VALUE)
		do
			items.force (create {ENV_ASSIGNMENT}.make (a_var_name, a_value))
		end

	add_call (a_command: ENV_VALUE; a_arguments: detachable ITERABLE [ENV_VALUE])
		do
			items.force (create {ENV_CALL}.make (a_command, a_arguments))
		end

feature -- Conversion

	comment (s: READABLE_STRING_GENERAL): ENV_SCRIPT_COMMENT
		do
			create Result.make (s)
		ensure
			is_class: class
		end

	string (s: READABLE_STRING_GENERAL): ENV_STRING_VALUE
		do
			Result := s
		ensure
			is_class: class
		end

	path (lst: ITERABLE [ENV_VALUE]): ENV_PATH_VALUE
		do
			create Result.make (lst)
		ensure
			is_class: class
		end

	variable (a_name: READABLE_STRING_GENERAL): ENV_VARIABLE
		do
			create Result.make (a_name)
		ensure
			is_class: class
		end


end
