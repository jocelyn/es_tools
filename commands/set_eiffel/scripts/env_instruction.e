note
	description: "Summary description for {ENV_INSTRUCTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENV_INSTRUCTION

feature -- Operation

	add alias "+" (a_script: ENV_INSTRUCTION): ENV_INSTRUCTION_GROUP
		do
			create Result.make (2)
			Result.extend (Current)
			Result.extend (a_script)
		end

feature -- 	Visitor

	accept (vis: ENV_VISITOR)
		deferred
		end

end
