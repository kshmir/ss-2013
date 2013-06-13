module Simulator
	module Strategy
		module RequestProcessor

			class Base
				attr_reader :queue, :queue_limit

				def initialize params = {}
					@queue = []
					@queue_limit = params[:input_variables][:queue_limit]
				end

				def is_queue_full?
					@queue.length >= @queue_limit
				end

				def is_queue_empty?
					@queue.length == 0
				end
			end

		end
	end
end

