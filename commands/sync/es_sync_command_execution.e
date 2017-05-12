note
	description: "Summary description for {ES_SYNC_COMMAND_EXECUTION}."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_SYNC_COMMAND_EXECUTION

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

	make (ctx: ES_SYNC_CONTEXT)
		do
			context := ctx
			is_recursive := ctx.is_recursive
			is_verbose := ctx.is_verbose
			is_simulation := ctx.is_simulation
		end

	context: ES_SYNC_CONTEXT

feature -- Status

	is_path_matching_exclusions (p: PATH; lst: detachable LIST [READABLE_STRING_32]): BOOLEAN
		local
			f: READABLE_STRING_32
			l_name: READABLE_STRING_32
			kmp: KMP_WILD
		do
			if lst = Void or else lst.is_empty then
					-- Not excluded
			else
				l_name := p.name
				across
					lst as ic
				until
					Result
				loop
					f := ic.item
					if f.has ('*') or f.has ('?') then
							-- Regexp!!
						create kmp.make (f, l_name)
						Result := kmp.found
					else
						Result := l_name.same_string (f)
					end
				end
			end
		end

	path_excluded (pn: PATH; a_parent_directory: PATH): BOOLEAN
		do
			Result := Precursor (pn, a_parent_directory)
			if not Result then
				Result := is_path_matching_exclusions (pn, context.path_exclusions)
			end
		end

	directory_excluded (dn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is Directory `dn' excluded?
		local
			s: READABLE_STRING_32
		do
			Result := Precursor (dn, a_parent_directory)
			if not Result then
				Result := is_path_matching_exclusions (dn, context.directory_exclusions)
			end
--			s := dn.name
--			Result := s.same_string_general ("EIFGENs")
--				or s.starts_with_general (".")
		end

	file_excluded (fn: PATH; a_parent_directory: PATH): BOOLEAN
			-- Is file `fn' excluded?
		do
			Result := Precursor (fn, a_parent_directory)
			if not Result and attached context.included_extensions as lst then
				Result := True
				if attached fn.extension as ext then
					if across lst as ic some ext.same_string (ic.item) end then
						Result := False
					end
				end
			end
			if not Result then
				Result := is_path_matching_exclusions (fn, context.file_exclusions)
			end
		end

end
