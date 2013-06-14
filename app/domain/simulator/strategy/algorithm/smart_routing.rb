module Simulator
	module Strategy
		module Algorithm
			class SmartRouting < Algorithm::Base
				def initialize clients
					super clients
					@last_chosen = -1
				end

				def compute
					super

					# in the case all the dynos are busy,
					# return no dyno
					# return nil if @clients.count { |dyno| dyno.queue.size == 0 } == 0
					
					available_clients = @clients.reject { |dyno| !dyno.idle? }.shuffle
					if available_clients.empty?
						client = nil
					else
						client = available_clients[0]
					end
				end
			end

		end
	end
end
