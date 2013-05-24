module Simulator
	module Strategy
		module Algorithm
			class RandomRouting < Base
				def initialize seed=Time.now.to_i, client
					super clients
					@@fish_monger = Random.new(seed) 
					#TODO: the pseudorandom generator shouldn't be called
					#fish_monger as it's not used with a Poisson distribution
				end

				def compute
					super
					until found_a_dyno do # Review this... it will be too slow
						client = @clients[@@fish_monger.new(@clients.length)]
						found_a_dyno = not client.is_queue_full?
					end
					client
				end
			end
		end
	end
end


