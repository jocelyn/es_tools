note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ES_SETUP_TOOL

inherit
	ES_COMMAND_TOOL
		rename
			launch as make
		end

	ES_SETUP_COMMAND

create
	make

end
