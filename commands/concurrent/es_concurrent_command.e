note
	description : "Objects that ..."
	author      : "$Author$"
	date        : "$Date$"
	revision    : "$Revision$"

class
	ES_CONCURRENT_COMMAND

inherit
	ES_COMMAND_WITH_HELP

	SHARED_EXECUTION_ENVIRONMENT

	THREAD_CONTROL

feature -- Status report

	is_available: BOOLEAN = True
			-- Is current command available?

feature -- Access

	description: detachable IMMUTABLE_STRING_32
		do
			Result := "concurrent batch"
		end

feature -- Execution

	execute_command (ctx: ES_COMMAND_CONTEXT)
		local
			i, n,m: INTEGER
			cmd: READABLE_STRING_32
			threads: ARRAYED_LIST [THREAD]
			wk: WORKER_THREAD
		do
			if attached ctx.arguments as args and then args.count = 3 then
				args.start
				n := args.item.to_integer
				args.forth
				m := args.item.to_integer
				args.forth
				cmd := args.item
				from
					create threads.make (n)
					i := 1
				until
					i > n
				loop
					create wk.make (agent (a_proc_id: INTEGER; nb: INTEGER; a_cmd: READABLE_STRING_32; is_verbose: BOOLEAN)
						local
							p: INTEGER
						do
							from p := 1 until p > nb loop
								if is_verbose then
									print ("> #" + a_proc_id.out + "." + p.out + "%N")
								end
								execution_environment.system (a_cmd)
								p := p + 1
							end
						end(i, m, cmd.twin, ctx.is_verbose)
					)
					threads.force (wk)
					i := i + 1
				end

				across
					threads as c
				loop
					c.item.launch
				end

				join_all
			else
				execute_help (ctx)
			end
		end

	execute_help (ctx: ES_COMMAND_CONTEXT)
		do
			printer.localized_print ("Run concurrent execution.%N")
			printer.localized_print ("Usage: concurrent N M command.%N")
			printer.localized_print ("%TN: number of concurrent processor%N")
			printer.localized_print ("%TM: number of execution of each processor%N")
		end

end
