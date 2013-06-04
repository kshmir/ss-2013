module Simulator
	module Strategy
		module RequestProcessor

			class Client < Base
				attr_accessor :processed_req
				attr_reader :endtime, :current_request, :id, :cumulative_idle_time
				@@counter = 0

				def initialize params = {}
					super params
					@start_idle_time = 0
					@idle = true
					@cumulative_idle_time = 0
					@endtime = 0
					@queue_limit ||= 100
					@exit_time_generator = params[:exit_time_generator]
					@id = @@counter
					@@counter += 1
					@processed_req = []
				end

				def enqueue_request current_time, req
					req.enter_into_dyno_time = current_time
					if @idle
						@idle = false
						@cumulative_idle_time += current_time - @start_idle_time
						@endtime = current_time + @exit_time_generator.calculate
						@current_request = req
					else
						@queue << req
					end
				end

				def finish_request 
					#@endtime is the current_time when this function is called
					@current_request.exit_from_dyno_time = @endtime 
					@processed_req << @current_request
					if @queue.empty?
						@idle = true
						@start_idle_time = @endtime
						@current_request = nil
					else
						@current_request = @queue.shift
						@endtime += @exit_time_generator.calculate
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