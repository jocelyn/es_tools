note
	description: "Summary description for {ENV_PATH_VALUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_PATH_VALUE

inherit
	ENV_VALUE

create
	make

feature {NONE} -- Initialization

	make (lst: ITERABLE [ENV_VALUE])
		do
			create {ARRAYED_LIST [ENV_VALUE]} items.make (1)
			across
				lst as c
			loop
				items.force (c.item)
			end
		end

feature -- Access		

	items: LIST [ENV_VALUE]

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		do
			vis.visit_path (Current)
		end


end
