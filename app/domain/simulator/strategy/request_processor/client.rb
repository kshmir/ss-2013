module Simulator
	module Strategy
		module RequestProcessor

			class Client < RequestProcessor::Base
				attr_accessor :processed_req
				attr_reader :endtime, :current_request, :id
				@@counter = 0

				def initialize params = {}
					super params
					@start_idle_time = 0
					@idle = true
					@cumu_idle_time = 0
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
						@cumu_idle_time += current_time - @start_idle_time
						@endtime = current_time + @exit_time_generator.calculate
						@current_request = req
						@current_request.beginning_of_processing_time = current_time
					else
						@queue << req
					end
				end

				def finish_request 
					#@endtime is the current_time when this function is called
					new_current_time = @endtime
					@current_request.exit_from_dyno_time = new_current_time
					@processed_req << @current_request
					if @queue.empty?
						@idle = true
						@start_idle_time = new_current_time
						@current_request = nil
					else
						@current_request = @queue.shift
						@current_request.beginning_of_processing_time = new_current_time
						@endtime += @exit_time_generator.calculate
					end
				end

				def cumulative_idle_time t
					idle? ? @cumu_idle_time + t - @start_idle_time : @cumu_idle_time
				end

				def idle?
					@idle
				end
			end

		end
	end
end
