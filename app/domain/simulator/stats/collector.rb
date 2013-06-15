module Simulator
	module Stats

		class Collector
			attr_reader :results

			def initialize clients
				@clients = clients
				@results = {clients_stats: [], req_stats: 0}
				@grapher = Simulator::Stats::Grapher.new @clients.size, @clients.map { |c| "dyno #{c.id}" }
			end

			def display_and_plot
				puts @results
#         @grapher.plot
			end

			def collect_stats t
				stats = { time: t,
									queue_size: @clients.map { |c| c.queue.size },
								  idle_time:  @clients.map { |c| c.cumulative_idle_time t } }
				@results[:clients_stats] << stats
				stats
			end

			def collect_req_stats req
				stats = { id: req.id }
				[:enter_into_router_time, :enter_into_dyno_time, :beginning_of_processing_time, :exit_from_dyno_time].each do |time|
					stats[time] = req.send time
				end
				@results[:req_stats] += req.beginning_of_processing_time - req.enter_into_router_time
				stats
			end

		end
	end
end



