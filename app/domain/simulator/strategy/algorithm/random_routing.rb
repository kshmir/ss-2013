module Simulator
	module Strategy
		module Algorithm
			class RandomRouting < Base
				def initialize seed=Time.now.to_i, clients
					super clients
					@@fish_monger = Random.new(seed) 
					#TODO: the pseudorandom generator shouldn't be called
					#fish_monger as it's not used with a Poisson distribution
				end

				def compute
					super
				  client = nil
					attempt = 0
					loop do # Review this... it will be too slow
						attempt += 1
						client = @clients[@@fish_monger.rand(@clients.length)]
						break if !client.is_queue_full? || attempt > @clients.length * 3
					end
					client.is_queue_full? ? nil : client
				end
			end
		end
	end
end


