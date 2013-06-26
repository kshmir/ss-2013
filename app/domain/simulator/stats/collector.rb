class Array
	def mean
		reduce(0.0,:+) / length
	end

	def standard_deviation 
		m = mean 
		(map { |x| (x-m)**2.0 }).mean ** 0.5
	end
end


module Simulator
	module Stats

		class Collector
			attr_reader :results

			def initialize clients
				@clients = clients
				@results = {idle_times: [], durations: [], consolidated: { mean_idle_time: 0, mean_duration: 0, std_dev_idle_time: 0, std_dev_duration: 0 } }
				@grapher = Simulator::Stats::Grapher.new @clients.size, @clients.map { |c| "dyno #{c.id}" }
			end

			def display_and_plot
				puts @results
			end

			def collect_stats t, stats
				[:enter_into_router_time, :enter_into_dyno_time, :beginning_of_processing_time, :exit_from_dyno_time, :dyno].each do |attr|
					stats[attr] = req.send attr
				end
				@results[:durations] << stats[:beginning_of_processing_time] - stats[:enter_into_router_time];
				stats
			end

			def finalize_stats t, number_of_iterations
				@results[:idle_times] = @clients.map { |dyno| dyno.cumulative_idle_time t }
				@results[:consolidated][:mean_idle_time] = @results[:idle_times].mean
				@results[:consolidated][:mean_duration] = @results[:durations].mean
				@results[:consolidated][:std_dev_idle_time] = @results[:idle_times].standard_deviation
				@results[:consolidated][:std_dev_duration] = @results[:durations].standard_deviation
			end

		end
	end
end

