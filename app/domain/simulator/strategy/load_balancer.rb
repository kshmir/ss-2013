module Simulator
	module Strategy
		class LoadBalancer < Strategy::Base

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
				dyno_to_consider = get_dyno_by_next_exit_time
				stats = {}

				if !dyno_to_consider.nil? && dyno_to_consider.endtime < @next_arrival_time
					@t = dyno_to_consider.endtime
					req = dyno_to_consider.finish_request
					@stats_collector.collect_req_stats req
					dispatch_queue
					stats = { event_type: :arrival }
				else
					@t = @next_arrival_time
					req = Request.new @t
					if not @router.is_queue_full?
						@router.queue << req
						@accepted += 1
						dispatch_queue
					else
						@rejected += 1
					end
					interarrival_time = @next_arrival.calculate
					@next_arrival_time = @t + interarrival_time
					@current_iteration += 1
					stats = { event_type: :exit }
				end

				@stats_collector.collect_stats @t, stats
				yield(@current_iteration, @max_amount_of_iterations, stats, req) if block_given?
			end

			def terminate
				@next_arrival_time = Float::INFINITY
				loop do
					req = get_dyno_by_next_exit_time.finish_request
					dispatch_queue
					stats = { event_type: :exit}
					@stats_collector.collect_stats @t, stats
					break if @clients.all? { |dyno| dyno.idle? }
				end
#         @stats_collector.display_and_plot
				@stats_collector.results
			end

			def self.with_algorithm algorithm, params = {}
				params[:input_variables] ||= {}
				params[:obj_functions] ||= {}
				LoadBalancer.new params.merge!( control_functions: { algorithm: algorithm } )
			end

			private
			def init
				@t = 0
				@next_arrival_time = 0
				@next_exit_time = Float::INFINITY

				@accepted = 0
				@rejected = 0

				@current_iteration = 0
				@max_amount_of_iterations = input_variables[:max_amount_of_iterations] || 100

				@next_arrival = input_variables[:next_arrival_time] || (Simulator::Strategy::RandomVariable.new :rpois, lambda: 6.667) 
				@next_exit = input_variables[:next_exit_time] || (Simulator::Strategy::RandomVariable.new :rweibull, {shape: 0.46, scale: 111}, 10, 30000)
				@router = Simulator::Strategy::RequestProcessor::Router.new params
				@clients_limit = input_variables[:clients_limit] || 10
				@clients = (1..@clients_limit).map { Simulator::Strategy::RequestProcessor::Client.new( params.merge!({exit_time_generator: @next_exit}) )}
				@algorithm = control_functions[:algorithm].send :new, @clients
				@stats_collector = Simulator::Stats::Collector.new @clients
			end


			def get_dyno_by_next_exit_time
				@clients.reject { |dyno| dyno.idle? }
								.min_by { |dyno| dyno.endtime }
			end

			def dispatch_queue
				elected_clients = []
				loop do
					dyno = @algorithm.compute
					break if @router.queue.size <= 0 || dyno.nil?
					req = @router.queue.shift
					dyno.enqueue_request @t, req
					elected_clients << dyno.id
				end
				elected_clients
			end

		end
	end
end
