module Simulator
	module Strategy
		class LoadBalancer < Base

			def initialize params = {}
				super(params)
				init
			end

			def verify!
				# TODO: Make this work fine
				# begin
				# 	raise "Invalid Algoritm" if control_functions[:algorithm].responds_to? :compute
				# rescue Exception => e
				# 	raise "Expected algorithm!" if control_functions[:algorithm].nil?
				# 	binding.pry
				# 	raise "Unexpected error"
				# end
			end

			def finished?
				@current_iteration >= @max_amount_of_iterations
			end

			def step
				interarrival_time = @next_arrival_time.calculate
				next_arrival = @t + interarrival_time
				finish_dyno_requests(next_arrival)
				@t = next_arrival
				req = Request.new @t
				if not @router.is_queue_full?
					@router.queue << req
					@accepted += 1
					dispatch_queue_at @t
				else
					@rejected += 1
				end

				stats = @stats_collector.collect_stats @t
				@current_iteration = @current_iteration + 1
				yield(@current_iteration, @max_amount_of_iterations, stats)
			end

			def terminate
					finish_dyno_requests Float::INFINITY
					@stats_collector.display_and_plot
			end

			def self.with_algorithm algorithm, params = {}
				params[:input_variables] ||= {}
				params[:obj_functions] ||= {}
				LoadBalancer.new params.merge!( control_functions: { algorithm: algorithm } )
			end

			private
			def init
				@t = 0
				@accepted = 0
				@rejected = 0
				@arrival_times = []
				@current_iteration = 0
				@max_amount_of_iterations = input_variables[:max_amount_of_iterations] || 10000
				@next_arrival_time = input_variables[:next_arrival_time] || (Simulator::Strategy::RandomVariable.new :rpois, lambda: 150) 
				@next_exit_time = input_variables[:next_exit_time] || (Simulator::Strategy::RandomVariable.new :rweibull, shape: 0.46, scale: 110.92)
				@rejected_size = 0
				@router = Simulator::Strategy::RequestProcessor::Router.new params
				@clients_limit = input_variables[:clients_limit] || 10
				@clients = (1..@clients_limit).map { Simulator::Strategy::RequestProcessor::Client.new( params.merge!({exit_time_generator: @next_exit_time}) )}
				@algorithm = control_functions[:algorithm].send :new, @clients
				@stats_collector = Simulator::Stats::Collector.new @clients
			end


			def finish_dyno_requests arrival_time
				loop do
					next_dynos = next_dynos_for arrival_time
					break	if next_dynos.empty?
					next_dynos.each { |dyno| @t = dyno.finish_request }
					dispatch_queue_at @t
				end
			end

			def next_dynos_for arrival_time
				@clients.reject { |dyno| dyno.idle? }
								.select { |dyno| dyno.endtime < arrival_time }
				        .sort! { |dyno1,dyno2| dyno1.endtime <=> dyno2.endtime }
			end

			def dispatch_queue_at time
				loop do
					dyno = @algorithm.compute
					break if @router.queue.size <= 0 || dyno.nil?
					req = @router.queue.shift
					dyno.enqueue_request time, req
				end
			end

		end
	end
end
