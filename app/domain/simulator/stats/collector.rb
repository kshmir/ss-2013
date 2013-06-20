module Simulator
	module Stats

		class Collector
			attr_reader :results

			def initialize clients
				@clients = clients
				@results = {clients_stats: [], consolidated_stats: { total_queueing_time: 0, req_queued: 0 } }
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
				stats = {}
				[:id, :enter_into_router_time, :enter_into_dyno_time, :beginning_of_processing_time, :exit_from_dyno_time, :dyno].each do |attr|
					stats[attr] = req.send attr
				end
				@results[:consolidated_stats][:total_queueing_time] += req.beginning_of_processing_time - req.enter_into_router_time
				@results[:consolidated_stats][:req_queued] += 1 if req.enter_into_router_time != req.beginning_of_processing_time
				stats
			end

		end
	end
end



