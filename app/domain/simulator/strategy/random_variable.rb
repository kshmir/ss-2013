module Simulator
	module Strategy

			class RandomVariable
				attr_accessor :method, :params

				def initialize method, params = {}, min = 0, max = Float::INFINITY
					@@r ||= RSRuby.instance
					@method = method
					@params = params
					@bounds = {min: min, max: max}
				end

				def calculate n = 1
					@@r.pmin(@bounds[:max], @@r.pmax(@bounds[:min], @@r.send(@method, n, @params)))
				end
			end

	end
end
