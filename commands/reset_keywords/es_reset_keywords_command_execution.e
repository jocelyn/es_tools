note
	description: "Summary description for {ES_RESET_KEYWORDS_COMMAND_EXECUTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_RESET_KEYWORDS_COMMAND_EXECUTION

inherit
	FS_HELPERS
		redefine
			path_excluded,
			directory_excluded,
			file_excluded
		end

create
	make

feature {NONE} -- Initialization

	make (ctx: like context)
		do
			context := ctx
			is_recursive := ctx.is_recursive
			is_verbose := ctx.is_verbose
			is_simulation := ctx.is_simulation
		end

	context: ES_RESET_KEYWORDS_CONTEXT

feature -- Status

	path_excluded (pn: PATH; a_parent_directory: PATH): BOOLEAN
		do
			Result := Precursor (pn, a_parent_directory)
			if not Result then
				Result := context.path_excluded (pn)
			end
		end

	directory_excluded (dn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is Directory `dn' excluded?
		do
			Result := Precursor (dn, a_parent_directory)
			if not Result then
				Result := context.directory_excluded (dn)
			end
		end

	file_excluded (fn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is file `fn' excluded?
		do
			Result := Precursor (fn, a_parent_directory)
			if not Result then
				Result := context.file_excluded (fn)
			end
		end

end
