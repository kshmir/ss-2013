module Simulator
	module Strategy
		module RequestProcessor

			class Client < Base
				attr_accessor :idle, :endtime, :current_request, :id
				@@counter = 0

				def initialize params = {}
					super params
					@idle = true
					@endtime = 0
					@queue_limit ||= 100
					@exit_time_generator = params[:exit_time_generator]
					@id = @@counter
					@@counter += 1
				end

				def enqueue_request current_time, req
					req.enter_into_dyno_time = current_time
					puts "req #{req.id} entered dyno #{@id}"
					if @idle
						@idle = false
						@endtime = current_time + @exit_time_generator.calculate
						puts "req #{req.id} is scheduled to leave at #{@endtime}"
						@current_request = req
					else
						@queue << req
					end
				end

				def finish_request
					@current_request.exit_from_dyno_time = @endtime 
					puts "end of request #{@current_request.id} (#{@current_request.enter_into_router_time},"+
																											"#{@current_request.enter_into_dyno_time},"+
																											"#{@current_request.exit_from_dyno_time})\n"
					if @queue.empty?
						@idle = true
						@current_request = nil
					else
						@current_request = @queue.shift
						@endtime += @exit_time_generator.calculate
						puts "req #{@current_request.id} is scheduled to leave at #{@endtime}"
					end
					@endtime
				end

				def idle?
					@idle
				end
			end

		end
	end
end
