note
	description: "Summary description for {ENV_STRING_VALUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_STRING_VALUE

inherit
	ENV_VALUE

create
	make

convert
	make ({READABLE_STRING_GENERAL, READABLE_STRING_8, READABLE_STRING_32})

feature {NONE} -- Initialization

	make (v: READABLE_STRING_GENERAL)
		do
			create value.make_from_string_general (v)
		end

feature -- Access

	value: IMMUTABLE_STRING_32

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		do
			vis.visit_string (Current)
		end

end
