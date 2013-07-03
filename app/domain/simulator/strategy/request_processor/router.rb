module Simulator
	module Strategy
		module RequestProcessor

			class Router < RequestProcessor::Base
				attr_reader :queue_limit
				def initialize params = {}
					super params
					@queue_limit ||= 5000
				end				
			end

		end
	end
end

