module Simulator
	module Strategy
		class LoadBalancer < Base

			def initialize params
				super(params)
				init
			end



			def verify!
				begin
					raise "Invalid Algoritm" if control_functions[:algorithm].responds_to? :compute_next_dyno_to_use
				rescue
					raise "Expected algorithm!" if control_functions[:algorithm].nil?
					raise "Unexpected error"
				end
			end

			def finished?
				@current_iteration > @max_amount_of_iterations
			end

			def step
				arrival_time = @next_arrival_time.calculate
				finish_requests arrival_time


			end

			def self.with_algorithm algorithm, params = {}
				LoadBalancer.new params.merge!( obj_functions: { algorithm: algorithm } )
			end

			private
			def init
				@algorithm = control_functions[:algorithm] 
				@t = 0
				@arrival_times = []
				@current_iteration = 0
				@max_amount_of_iterations = input_variables[:max_amount_of_iterations] || 10000
				@next_arrival_time = RandomVariable.new :dpois, lambda: 5 
				@next_exit_time = RandomVariable.new :dnorm, lambda: 5, mean: 30
				@rejected_size = 0
				@main_queue = Router.new params
				@clients_limit = input_variables[:clients_limit] || 10
				@clients = (1..@clientAmount).map { Client.new(params) }
			end

			class RandomVariable
				attr_accessor :method, :params

				def initialize method, params = {}
					@@r ||= RSRuby.instance
					@method = method
					@params = params
				end

				def calculate n = 1
					@@r.send(@method, n, @params)
				end

			end

			class Router
				attr_accessor :queue

				def init params = {}
					queue = Queue.new
					queueLimit = params[:input_variables][:queue_limit] || 1000
				end				
			end

			class Client
				attr_accessor :queue, :idle, :endtime

				def init params = {}
					queue = Queue.new
					idle = false
					endtime = 0
					queueLimit = params[:input_variables][:queue_limit] || 100
				end

				def is_queue_full?
						queue.length >= queueLimit
				end
			end

			def finish_requests arrival_time
				dyno_ending_before_next_arrival = @clients.select { |dyno| arrival_time < dyno.endtime }
				until dyno_ending_before_next_arrival == [] do
						dyno_ending_before_next_arrival.sort! { |dyno1,dyno2| dyno1.endtime <=> dyno2.endtime }

						dyno_ending_before_next_arrival.each do |dyno|
								@T = dyno.endtime
								if dyno.queue.length == 0
										idle = true
										# principio de tiempo ocioso
								else
										dyno.queue.deq
								end
						end
						dispatch_from_main_queue
						dyno_ending_before_next_arrival = @clients.select { |dyno| arrival_time < dyno.endtime }
				end
			end

			def dispatch_from_main_queue
					dyno = @algorithm.compute_next_dyno_to_use @clients 
					unless dyno.nil?
							request = queue.pop
							if dyno.idle?
									dyno.idle = false
									#incrementar tiempo de ociosidad
							end
							dyno.queue.push request
							dyno.endtime = @T + @next_exit_time.calculate
					end
			end


			# Cool stuff
		end
	end
end
