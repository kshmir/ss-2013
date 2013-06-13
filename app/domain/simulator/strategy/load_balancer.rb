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
				interarrival_time = @next_arrival_time.calculate
				next_arrival = @t + interarrival_time
				finish_dyno_requests(next_arrival)
				@t = next_arrival
				req = Request.new @t
				elected_clients = []
				if not @router.is_queue_full?
					@router.queue << req
					@accepted += 1
					elected_clients = dispatch_queue_at @t
				else
					@rejected += 1
				end

				stats = @stats_collector.collect_stats @t
				@current_iteration = @current_iteration + 1
				yield(@current_iteration, @max_amount_of_iterations, stats, elected_clients) if block_given?
			end

			def terminate
					finish_dyno_requests Float::INFINITY
					stats = @stats_collector.collect_stats @t
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
				@max_amount_of_iterations = input_variables[:max_amount_of_iterations] || 100
				@next_arrival_time = input_variables[:next_arrival_time] || (Simulator::Strategy::RandomVariable.new :rpois, lambda: 1) 
				@next_exit_time = input_variables[:next_exit_time] || (Simulator::Strategy::RandomVariable.new :rweibull, shape: 0.8, scale: 79.6)
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
					next_dynos.each do |dyno| 
						@t = dyno.finish_request
						dispatch_queue_at @t
					end
					break	if next_dynos.empty?
				end
			end

			def next_dynos_for arrival_time
				@clients.reject { |dyno| dyno.idle? }
								.select { |dyno| dyno.endtime < arrival_time }
				        .sort! { |dyno1,dyno2| dyno1.endtime <=> dyno2.endtime }
			end

			def dispatch_queue_at time
				elected_clients = []
				loop do
					dyno = @algorithm.compute
					break if @router.queue.size <= 0 || dyno.nil?
					req = @router.queue.shift
					dyno.enqueue_request time, req
					elected_clients << dyno.id
				end
				elected_clients
			end

		end
	end
end
