module Simulator
	module Strategy
		module Algorithm
			class RoundRobinRouting < Algorithm::Base
				def initialize clients
					super clients
					@last_elected = -1
				end

				def compute
					return nil if @clients.reject { |x| x.nil? }.count { |dyno| dyno.is_queue_full? } >= @clients.reject { |x| x.nil? }.count

				  client = nil
					loop do
						@last_elected = (@last_elected + 1) % @clients.size 
						client = @clients[@last_elected]
						break if !client.is_queue_full?
					end
					client.is_queue_full? ? nil : client
				end
			end
		end
	end
end
