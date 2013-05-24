module Simulator
	module Strategy
		module Algorithm
			class RoundRobinRouting < Base
				def initialize clients
					super clients
					@last_elected = 0
				end

				def compute
					super

					loop do
						@last_elected += 1
						client = @clients[@last_elected]
						break if client.is_queue_full?
					end
					client
				end
			end
		end
	end
end
