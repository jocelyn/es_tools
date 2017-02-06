note
	description: "[
				Custom Environment configuration for EiffelStudio with version override.
			]"
	date: "$Date$"
	revision: "$Revision$"

class
	ES_EIFFEL_VERSIONED_LAYOUT

inherit
	ES_EIFFEL_LAYOUT
		redefine
			default_create,
			version_name
		end

	SHARED_EXECUTION_ENVIRONMENT
		redefine
			default_create
		end

create
	make_with_version,
	default_create

feature -- Initialization

	default_create
			-- Instantiate Current based on content of file $ISE_EIFFEL/VERSION if any.
		local
			p: PATH
			f: PLAIN_TEXT_FILE
			s: detachable STRING
			i: INTEGER
		do
			if attached execution_environment.item ("ISE_EIFFEL") as l_ise_eiffel_var then
				create p.make_from_string (l_ise_eiffel_var)
				create f.make_with_path (p.extended ("VERSION"))
				if f.exists and then f.is_access_readable then
					f.open_read
					f.read_line
					s := f.last_string
						-- Expecting line formatted as "ISE Eiffel 2016, release 16.05."
					i := s.substring_index ("release", 1)
					if i > 0 then
						s.remove_head (i + 7)
						s.left_adjust
						s.right_adjust
						if s.ends_with (".") then
							s.remove_tail (1)
							s.right_adjust
							i := s.index_of ('.', 1)
							if
								i > 0 and then
								s.head (i - 1).is_integer and then
								s.tail (s.count - i).is_integer
							then
									-- Found version
							else
								s := Void
							end
						end
					end
					f.close
				end
				if s /= Void then
					make_with_version (s)
				else
					Precursor
				end
			else
				Precursor
			end
		end

	make_with_version (a_version: STRING_8)
		do
			custom_version_name := a_version
		end

feature -- Access

	custom_version_name: detachable STRING_8

	version_name: STRING_8
			-- Version string.
			-- I.e. MM.mm
		do
			if attached custom_version_name as v then
				Result := v
			else
				Result := Precursor
			end
		end

end
