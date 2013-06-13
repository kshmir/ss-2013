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
					
					index = @last_chosen
					client = nil
					loop do
						index = (index + 1) % clients.length
						client = @clients[index]
						break if index == (@last_chosen + 1) % clients.length || client.idle?
					end
					if client.idle? 
						@last_chosen = index
					else
						client = nil
					end
					client
				end
			end

		end
	end
end
