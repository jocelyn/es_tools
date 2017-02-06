note
	description: "Summary description for {ES_TOOL_CONSTANTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_TOOL_CONSTANTS

feature -- Constants

	product_name: STRING_32 = "Tool-Launcher"

	version_major: NATURAL_16 = 1

	version_minor: NATURAL_16 = 0

	es_ini_filename: STRING_32 = "config"

	es_info_extension: STRING_32 = "es-info"

	group_separator: CHARACTER_8 = ':'

end
