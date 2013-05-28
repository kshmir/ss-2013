module Simulator
	module Strategy

			class RandomVariable
				attr_accessor :method, :params

				def initialize method, params = {}
					@@r ||= RSRuby.instance
					@method = method
					@params = params
				end

				def calculate n = 1
					@@r.send(@method, n, @params)
				end
			end

	end
end
