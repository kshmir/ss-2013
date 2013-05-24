module Simulator
	module Strategy
		module Algorithm
			class Base
				attr_accessor :clients

				def initialize clients
					@clients = clients
				end

				def compute
					#this function should not be called if there is no dyno available
					#because of the most infinite loop that would follow
					return nil if @clients.reject { |x| x.nil? }.count { |dyno| dyno.queue.size > 0 } <= 0
				end
			end
		end
	end
end
