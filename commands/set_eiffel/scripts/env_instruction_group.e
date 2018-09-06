note
	description: "Summary description for {ENV_INSTRUCTION_GROUP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_INSTRUCTION_GROUP

inherit
	ENV_INSTRUCTION

	ITERABLE [ENV_INSTRUCTION]

create
	make

feature {NONE} -- Initialization

	make (nb: INTEGER)
		do
			create {ARRAYED_LIST [ENV_INSTRUCTION]}	items.make (nb)
		end

feature -- Change

	extend (i: ENV_INSTRUCTION)
		do
			items.force (i)
		end

	append (lst: ITERABLE [ENV_INSTRUCTION])
		do
			across
				lst as ic
			loop
				extend (ic.item)
			end
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [ENV_INSTRUCTION]
			-- Fresh cursor associated with current structure
		do
			Result := items.new_cursor
		end

feature -- Access

	items: LIST [ENV_INSTRUCTION]

feature -- Visitors

	accept (vis: ENV_VISITOR)
		do
			vis.visit_group (Current)
		end

end
