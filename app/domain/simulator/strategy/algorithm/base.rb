module Simulator
	module Strategy
		module Algorithm
			class Base
				attr_accessor :clients

				def initialize clients
					@clients = clients
				end

			end
		end
	end
end
