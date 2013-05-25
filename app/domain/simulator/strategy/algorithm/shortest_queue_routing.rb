module Simulator
	module Strategy
		module Algorithm
			class ShortestQueueRouting < Base
				def initialize clients
					super clients
				end

				def compute
					super
					# would it be useful to do a shuffle
					# to ensure not using always the same
					# minimum ?
					@clients.min_by { |dyno| dyno.queue.size }
				end
			end
		end
	end
end




