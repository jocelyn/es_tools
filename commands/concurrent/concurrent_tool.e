note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	CONCURRENT_TOOL

inherit
	ES_COMMAND_TOOL
		rename
			launch as make
		end

	ES_CONCURRENT_COMMAND

create
	make

end
