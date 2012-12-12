note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	UUID_TOOL

inherit
	ES_COMMAND_TOOL
		rename
			launch as make
		end

	ES_UUID_COMMAND

create
	make

end
