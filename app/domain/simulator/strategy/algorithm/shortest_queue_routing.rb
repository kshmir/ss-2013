module Simulator
	module Strategy
		module Algorithm
			class ShortestQueueRouting < Algorithm::Base
				def initialize clients
					super clients
				end

				def compute
					client = @clients.shuffle.min_by { |dyno| dyno.queue.size + (dyno.idle? ? 0 : 1) }
					client.is_queue_full? ? nil : client
				end
			end
		end
	end
end




