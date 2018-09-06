note
	description: "Summary description for {ENV_CALL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENV_CALL

inherit
	ENV_INSTRUCTION

create
	make

feature {NONE} -- Initialization

	make (a_cmd: ENV_VALUE; a_args: detachable ITERABLE [ENV_VALUE])
		do
			command := a_cmd
			arguments := a_args
		end

feature -- Access

	command: ENV_VALUE

	arguments: detachable ITERABLE [ENV_VALUE]

feature -- Visit

	accept (vis: ENV_VISITOR)
		do
			vis.visit_call (Current)
		end

end
