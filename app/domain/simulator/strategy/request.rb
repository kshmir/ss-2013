module Simulator
	module Strategy

			class Request
				attr_accessor :enter_into_router_time, 
											:enter_into_dyno_time,
											:beginning_of_processing_time,
											:exit_from_dyno_time,
											:id

				@@counter = 0

				def initialize time
					@enter_into_router_time = time
					@id = @@counter
					@@counter += 1
				end
			end

	end
end

