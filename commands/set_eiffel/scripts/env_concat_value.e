note
	description: "Summary description for {ENV_CONCAT_STRING_VALUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_CONCAT_VALUE

inherit
	ENV_VALUE

create
	make

feature {NONE} -- Initialization

	make (a_left, a_right: ENV_VALUE)
		do
			left := a_left
			right := a_right
		end

feature -- Access

	left, right: ENV_VALUE


end
