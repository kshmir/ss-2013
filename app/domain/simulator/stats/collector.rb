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
				stats = { queue_size: @clients.map { |c| c.queue.size },
								  idle_time:  @clients.map { |c| c.cumulative_idle_time } }
				@results[:clients_stats] << stats
				stats[:req_stats] = collect_req_stats!
#         @grapher.add t, stats[:queue_size]
				stats
			end


			private
			def collect_req_stats!
				req_stats = []
				@clients.each do |c|
					until c.processed_req.empty? do
						req = c.processed_req.shift
						req_stats << req #req.exit_from_dyno_time - req.enter_into_router_time
					end
				end
				@results[:req_stats] += req_stats.inject(0) do |mem,req|
					mem += req.exit_from_dyno_time - req.enter_into_router_time
				end
				req_stats
			end

		end
	end
end



