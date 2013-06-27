module Simulator
	module Strategy
		module RequestProcessor

			class Router < RequestProcessor::Base
				def initialize params = {}
					super params
					@queue_limit ||= 50
				end				
			end

		end
	end
end

