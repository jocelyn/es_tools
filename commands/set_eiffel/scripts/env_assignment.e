note
	description: "Summary description for {ENV_ASSIGNMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_ASSIGNMENT

inherit
	ENV_INSTRUCTION

create
	make

feature {NONE} -- Initialization

	make (a_var_name: READABLE_STRING_GENERAL; a_value: ENV_VALUE)
		do
			create name.make_from_string_general (a_var_name)
			value := a_value
		end

feature -- Access

	name: IMMUTABLE_STRING_32

	value: ENV_VALUE

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		do
			vis.visit_assignment (Current)
		end

end
