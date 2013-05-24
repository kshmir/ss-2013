module Simulator
	module Strategy
		module Algorithm
			class SmartRouting < Base
				def compute
					super

					# in the case all the dynos are busy,
					# return no dyno
					# return nil if @clients.count { |dyno| dyno.queue.size == 0 } == @clients.count

					index = -1
					client = nil
					loop do
						index += 1
						client = @clients[index]
						break if client.nil? || client.queue.size == 0
					end
					client
				end
			end

		end
	end
end
