module Simulator
		module Strategy
				module Algorithm

						class SmartRouting < Base
								def compute_next_dyno_to_use!
										super

										# in the case all the dynos are busy,
										# return no dyno
										return nil if @clients.count { |dyno| dyno.queue_length == 0 }

										index = -1
										until found_a_dyno do
												index += 1
												client = @clients[index]
												found_a_dyno = client.queue_length == 0
										end
										client
								end
						end

				end
		end
end
