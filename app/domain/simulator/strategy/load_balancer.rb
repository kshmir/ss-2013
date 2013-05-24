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
				# 	raise "Invalid Algoritm" if control_functions[:algorithm].responds_to? :compute_next_dyno_to_use
				# rescue Exception => e
				# 	raise "Expected algorithm!" if control_functions[:algorithm].nil?
				# 	binding.pry
				# 	raise "Unexpected error"
				# end
			end

			def finished?
				@current_iteration > @max_amount_of_iterations
			end

			def step
				arrival_time = @next_arrival_time.calculate
				finish_dyno_requests(@t + arrival_time)
				@t = @t + arrival_time
				dispatch_queue_at @t
				@current_iteration = @current_iteration + 1
			end

			def self.with_algorithm algorithm, params = {}
				params[:input_variables] ||= {}
				params[:obj_functions] ||= {}
				LoadBalancer.new params.merge!( control_functions: { algorithm: algorithm } )
			end

			private
			def init
				@t = 0
				@arrival_times = []
				@current_iteration = 0
				@max_amount_of_iterations = input_variables[:max_amount_of_iterations] || 100
				@next_arrival_time = RandomVariable.new :dpois, lambda: 5 
				@next_exit_time = RandomVariable.new :dnorm, sd: 5, mean: 30
				@rejected_size = 0
				@main_queue = Router.new params
				@clients_limit = input_variables[:clients_limit] || 10
				@clients = (1..@clients_limit).map { Client.new(params) }
				@algorithm = control_functions[:algorithm].send :new, @clients
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

				def initialize params = {}
					@queue = []
					@queueLimit = params[:input_variables][:queue_limit] || 1000
				end				
			end

			class Client
				attr_accessor :queue, :idle, :endtime

				def initialize params = {}
					@queue = []
					@idle = false
					@endtime = 0
					@queueLimit = params[:input_variables][:queue_limit] || 100
				end

				def is_queue_full?
					@queue.length >= @queueLimit
				end

				def idle?
					@idle
				end
			end

			def finish_dyno_requests arrival_time
				loop do
					next_dynos = next_dynos_for arrival_time
					next_dynos.each do |dyno|
							arrival_time = dyno.endtime
							if dyno.queue.length == 0
									idle = true
									# principio de tiempo ocioso
							else
									dyno.queue.deq
							end
					end
					break	if next_dynos.empty?
					dispatch_queue_at arrival_time
				end
			end

			def next_dynos_for arrival
				@clients.select { |dyno| arrival < dyno.endtime }
				        .sort! { |dyno1,dyno2| dyno1.endtime <=> dyno2.endtime }
			end

			def dispatch_queue_at time
					dyno = @algorithm.compute
					unless dyno.nil?
							request = dyno.queue.pop
							if dyno.idle?
									dyno.idle = false
									#incrementar tiempo de ociosidad
							end
							puts "Pushed into dyno #{dyno}, called from #{caller[0][/`.*'/][1..-2]}"
							dyno.queue.push request
							dyno.endtime = time + @next_exit_time.calculate
					end
			end


			# Cool stuff
		end
	end
end
