module Simulator
	module Strategy
		class LoadBalancer < Base

			def initialize params
				super(params)
				init
			end



			def verify!
				begin
					raise "Invalid Algoritm" if control_functions[:algorithm].responds_to? :do_queue
				rescue
					raise "Expected algorithm!" if control_functions[:algorithm].nil?
					raise "Unexpected error"
				end
			end

			def finished?
				@current_iteration > @max_amount_of_iterations
			end

			def step
				# @next_arrival_time.calculate = 
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
				@next_arrival_time = 0 # RandomVariable
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
					queue = []
					queueLimit = params[:input_variables][:queue_limit] || 1000
				end				
			end

			class Client
				attr_accessor :queue, :idle, :endtime

				def init params = {}
					queue = []
					idle = false
					endtime = 0
					queueLimit = params[:input_variables][:queue_limit] || 100
				end
			end
			# Cool stuff
		end
	end
end
