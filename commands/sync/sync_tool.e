note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	SYNC_TOOL

inherit
	ES_COMMAND_TOOL
		rename
			launch as make
		end

	ES_SYNC_COMMAND

create
	make

end
