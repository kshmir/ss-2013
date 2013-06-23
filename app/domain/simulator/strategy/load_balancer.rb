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
				stats = []

				if !dyno_to_consider.nil? && dyno_to_consider.endtime < @next_arrival_time
					@t = dyno_to_consider.endtime
					req = dyno_to_consider.finish_request
					stats <<  { time: @t, event: { event_type: :exit, req: req.id, dyno: req.dyno } }
					stats += dispatch_queue
				else
					@t = @next_arrival_time
					req = Request.new @t
					if not @router.is_queue_full?
						@router.queue << req
						stats << { time: @t, event: { event_type: :arrival, req: req.id } }
						@accepted += 1
					else
						stats << { time: @t, event: { event_type: :rejection, req: req.id } }
						@rejected += 1
					end
					interarrival_time = @next_arrival.calculate
					@next_arrival_time = @t + interarrival_time
					@current_iteration += 1
				end

				yield(@current_iteration, @max_amount_of_iterations, stats) if block_given?
			end

			def terminate
				@next_arrival_time = Float::INFINITY
				stats = []
				loop do
					break if @clients.all? { |dyno| dyno.idle? }
					dyno = get_dyno_by_next_exit_time
					@t = dyno.endtime
					req = get_dyno_by_next_exit_time.finish_request
					stats += dispatch_queue
					stats << { time: @t, event: { event_type: :exit, req: req.id, dyno: req.dyno } }
				end
				yield(@current_iteration, @max_amount_of_iterations, stats) if block_given?
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
			end


			def get_dyno_by_next_exit_time
				@clients.reject { |dyno| dyno.idle? }
								.min_by { |dyno| dyno.endtime }
			end

			def dispatch_queue
				stats = []
				loop do
					dyno = @algorithm.compute
					break if @router.queue.size <= 0 || dyno.nil?
					req = @router.queue.shift
					dyno.enqueue_request @t, req
					stats << { time: @t, event: { event_type: :routing, req: req.id, dyno: dyno.id } }
				end
				stats
			end

		end
	end
end
