note
	description: "Summary description for {ES_SYNC_CONTEXT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ES_SYNC_CONTEXT

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

end
