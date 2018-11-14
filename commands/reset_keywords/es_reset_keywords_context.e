note
	description: "Summary description for {ES_RESET_KEYWORDS_CONTEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_RESET_KEYWORDS_CONTEXT

inherit
	ANY
		redefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
		do
			is_recursive := True
		end

feature -- Access

	is_verbose: BOOLEAN assign set_is_verbose

	is_recursive: BOOLEAN assign set_is_recursive

	is_simulation: BOOLEAN assign set_is_simulation

	included_extensions: detachable ARRAYED_LIST [READABLE_STRING_32]

	path_exclusions: detachable ARRAYED_LIST [READABLE_STRING_32]
	directory_exclusions: detachable ARRAYED_LIST [READABLE_STRING_32]
	file_exclusions: detachable ARRAYED_LIST [READABLE_STRING_32]

	keywords: detachable ARRAYED_LIST [READABLE_STRING_GENERAL]

feature -- Status reports

	path_excluded (pn: PATH): BOOLEAN
		do
			Result := is_path_matching_exclusions (pn, path_exclusions)
		end

	directory_excluded (dn: PATH): BOOLEAN
			-- Is Directory `dn' excluded?
		do
			Result := is_path_matching_exclusions (dn, directory_exclusions)
		end

	file_excluded (fn: PATH): BOOLEAN
		do
			if attached included_extensions as lst then
				Result := True
				if attached fn.extension as ext then
					if across lst as ic some ext.same_string (ic.item) end then
						Result := False
					end
				end
			end
			if not Result then
				Result := is_path_matching_exclusions (fn, file_exclusions)
			end
		end

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
						Result := kmp.pattern_matches
					else
						Result := l_name.same_string (f)
					end
				end
			end
		end

feature -- Element change

	add_extension (ext: READABLE_STRING_32)
		local
			lst: like included_extensions
		do
			lst := included_extensions
			if lst = Void then
				create lst.make (1)
				included_extensions := lst
			end
			lst.force (ext)
		end

	add_path_exclusion (a_pattern: READABLE_STRING_32)
		local
			lst: like path_exclusions
		do
			lst := path_exclusions
			if lst = Void then
				create lst.make (1)
				path_exclusions := lst
			end
			lst.force (a_pattern)
		end

	add_directory_exclusion (a_pattern: READABLE_STRING_32)
		local
			lst: like directory_exclusions
		do
			lst := directory_exclusions
			if lst = Void then
				create lst.make (1)
				directory_exclusions := lst
			end
			lst.force (a_pattern)
		end

	add_file_exclusion (a_pattern: READABLE_STRING_32)
		local
			lst: like file_exclusions
		do
			lst := file_exclusions
			if lst = Void then
				create lst.make (1)
				file_exclusions := lst
			end
			lst.force (a_pattern)
		end

	set_is_verbose (b: like is_verbose)
		do
			is_verbose := b
		end

	set_is_recursive (b: like is_recursive)
		do
			is_recursive := b
		end

	set_is_simulation (b: like is_simulation)
		do
			is_simulation := b
		end

	add_keyword (k: READABLE_STRING_32)
		local
			lst: like keywords
		do
			lst := keywords
			if lst = Void then
				create lst.make (1)
				keywords := lst
			end
			lst.force (k)
		end

end
