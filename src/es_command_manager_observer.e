note
	description: "Summary description for {ES_COMMAND_MANAGER_OBSERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ES_COMMAND_MANAGER_OBSERVER

feature -- Event

	on_path_import (p: PATH)
		deferred
		end

	on_command_registered (cmd: ES_COMMAND; a_name: READABLE_STRING_GENERAL)
		deferred
		end

end
