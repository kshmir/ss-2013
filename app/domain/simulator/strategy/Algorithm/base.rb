module Simulator
		module Strategy
				module Algorithm
						class Base
								def init clients
										@clients = clients
								end

								def compute_next_dyno_to_use!
										#this function should not be called if there is no dyno available
										#because of the most infinite loop that would follow
										raise "No available dyno" if clients.count { |dyno| dyno.length > 0 } <= 0
								end
						end
				end
		end
end
