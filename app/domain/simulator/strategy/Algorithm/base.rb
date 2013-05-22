module Simulator
		module Strategy
				module Algorithm
						class Base
								def init clients
										@clients = clients
								end

								#subclasses will have to implement
								#a compute_next_dyno_to_use
						end
				end
		end
end
