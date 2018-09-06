note
	description: "Summary description for {ENV_VALUE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENV_VALUE

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		deferred
		end

end
