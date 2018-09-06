note
	description: "Summary description for {ENV_VISITOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENV_VISITOR

feature -- Visit

	visit_script (a_script: ENV_SCRIPT)
		deferred
		end

	visit_group (a_value: ENV_INSTRUCTION_GROUP)
		deferred
		end

	visit_call (a_value: ENV_CALL)
		deferred
		end

	visit_comment (a_value: ENV_SCRIPT_COMMENT)
		deferred
		end

	visit_string (a_value: ENV_STRING_VALUE)
		deferred
		end

	visit_path (a_value: ENV_PATH_VALUE)
		deferred
		end

	visit_variable (a_value: ENV_VARIABLE)
		deferred
		end

	visit_assignment (a_value: ENV_ASSIGNMENT)
		deferred
		end


end
