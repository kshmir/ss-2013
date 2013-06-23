module Simulator
	module Strategy
		module Algorithm
			class SmartRouting < Algorithm::Base
				def initialize clients
					super clients
					@last_chosen = -1
				end

				def compute
					
					available_clients = @clients.select { |dyno| dyno.idle? }.shuffle
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
