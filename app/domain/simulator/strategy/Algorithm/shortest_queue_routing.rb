module Simulator
		module Strategy
				module Algorithm

						class ShortestQueueRouting < Base
								def initialize
								end

								def compute_next_dyno_to_use!
										super
										# would it be useful to do a shuffle
										# to ensure not using always the same
										# minimum ?
										@clients.min_by { |dyno| dyno.queue_length }
								end
						end
				end
		end
end




