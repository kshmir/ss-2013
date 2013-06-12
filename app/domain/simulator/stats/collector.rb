module Simulator
	module Stats

		class Collector
			attr_reader :last_step_stats, :results

			def initialize clients
				@clients = clients
				@results = 0
				@nb = 0
#         @results = {clients_stats: [], req_stats: []}
#         @grapher = Simulator::Stats::Grapher.new @clients.size, @clients.map { |c| "dyno #{c.id}" }
			end


			def collect_stats t
					stats = nil
#         stats = { queue_size: @clients.map { |c| c.queue.size },
#                   idle_time:  @clients.map { |c| c.cumulative_idle_time } }
#         @results[:clients_stats] << stats

				req_stats = []
				@clients.each do |c|
					until c.processed_req.empty? do
						req = c.processed_req.shift
						req_stats << req.exit_from_dyno_time - req.enter_into_dyno_time
					end
				end
				@results += req_stats.inject(0, :+)
				@nb += req_stats.length
#         @results[:req_stats] += req_stats
#         stats[:req_stats] = req_stats
#         @last_step_stats = stats

#         @grapher.add t, stats[:queue_size]

				stats
			end

			def display_and_plot
#          puts @results
				puts (@results / @nb)
#          @grapher.plot
			end
		end

	end
end



