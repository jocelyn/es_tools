note
	description: "Summary description for {ENV_SCRIPT_COMMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_SCRIPT_COMMENT

inherit
	ENV_INSTRUCTION

create
	make

feature {NONE} -- Initialization

	make (a_text: READABLE_STRING_GENERAL)
		do
			create item.make_from_string_general (a_text)
		end

feature -- Access

	item: IMMUTABLE_STRING_32

	lines: LIST [READABLE_STRING_GENERAL]
		do
			Result := item.split ('%N')
		end

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		do
			vis.visit_comment (Current)
		end


end
