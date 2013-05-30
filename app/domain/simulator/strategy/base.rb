module Simulator
	module Strategy
		class Base
			attr_accessor :input_variables, 
										:obj_functions, 
										:control_functions, :params

			def initialize params = {}
				puts params.is_a? Hash
				@obj_functions = params[:obj_functions] || {}
				@input_variables = params[:input_variables] || {}
				@control_functions = params[:control_functions] || {}
				@params = params
			end
		end
	end
end
