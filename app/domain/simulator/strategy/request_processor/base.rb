module Simulator
	module Strategy
		module RequestProcessor

			class Base
				attr_accessor :queue, :queue_limit

				def initialize params = {}
					@queue = []
					@queue_limit = params[:input_variables][:queue_limit]
				end

				def is_queue_full?
					@queue.length >= @queue_limit
				end
			end

		end
	end
end

