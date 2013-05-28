module Simulator
	module Strategy
		module RequestProcessor

			class Router < Base
				def initialize params = {}
					super params
					@queue_limit ||= 1000
				end				
			end

		end
	end
end

