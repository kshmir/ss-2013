module Simulator
	module Strategy
		module Algorithm
			class RoundRobinRouting < Algorithm::Base
				def initialize clients
					super clients
					@last_elected = -1
				end

				def compute
					super
				  client = nil
					attempt = 0
					loop do
						attempt += 1
						@last_elected = (@last_elected + 1) % @clients.size 
						client = @clients[@last_elected]
						break if !client.is_queue_full? || attempt == @clients.size
					end
					client.is_queue_full? ? nil : client
				end
			end
		end
	end
end
