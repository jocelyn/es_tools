note
	description: "Objects that ..."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	BUILTIN_APPLICATION

inherit
	APPLICATION
		redefine 
			initialize_commands
		end

create
	make

feature {NONE} -- Initialization

	initialize_commands
		do
			Precursor

			manager.register (create {ES_LAYOUT_COMMAND}, "layout")
			manager.register (create {ES_UUID_COMMAND}.make_lowercase, "uuid")
			manager.register (create {ES_UUID_COMMAND}.make_uppercase, "UUID")
			manager.register (create {ES_SETUP_COMMAND}, "setup")
			manager.register (create {ES_WHICH_COMMAND}, "which")
			manager.register (create {ES_CONCURRENT_COMMAND}, "concurrent")
		end

end
