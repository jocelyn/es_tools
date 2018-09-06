note
	description: "Summary description for {ENV_VARIABLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_VARIABLE

inherit
	ENV_VALUE

create
	make

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_GENERAL)
		do
			create name.make_from_string_general (a_name)
		end

feature -- Access

	name: IMMUTABLE_STRING_32

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		do
			vis.visit_variable (Current)
		end

end
