note
	description: "Summary description for {ES_TOOL_CONSTANTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_TOOL_CONSTANTS

feature -- Constants

	product_name: STRING_32 = "Eiffel Software Tools"

	version_major: NATURAL_16 = 0

	version_minor: NATURAL_16 = 2

	es_config_folder: STRING_32 = ".es"

	es_ini_filename: STRING_32 = "es.ini"

	es_info_extension: STRING_32 = "es-info"

	group_separator: CHARACTER_32 = ':'

end
