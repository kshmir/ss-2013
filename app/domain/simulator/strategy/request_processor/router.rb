module Simulator
	module Strategy
		module RequestProcessor

			class Router < RequestProcessor::Base
				attr_reader :queue_limit
				def initialize params = {}
					super params
					@queue_limit ||= params[:input_variables][:clients_limit].nil? ? 1000 : params[:input_variables][:clients_limit] * 100
				end				
			end

		end
	end
end

