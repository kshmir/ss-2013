module Simulator
	module Strategy
		module Algorithm
			class ShortestQueueRouting < Algorithm::Base
				def initialize clients
					super clients
				end

				def compute
					super
					# would it be useful to do a shuffle
					# to ensure not using always the same
					# minimum ?
					client = @clients.min_by { |dyno| dyno.queue.size }
					client.is_queue_full? ? nil : client
				end
			end
		end
	end
end




