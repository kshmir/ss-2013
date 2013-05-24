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

					until found_a_dyno do
						@last_elected += 1
						client = @clients[@last_elected]
						found_a_dyno = not client.is_queue_full?
					end
					client
				end
			end
		end
	end
end
