module Simulator
	module Stats

		class Collector
			attr_reader :results

			def initialize clients
				@clients = clients
				@results = {clients_stats: [], req_stats: {}}
				@grapher = Simulator::Stats::Grapher.new @clients.size, @clients.map { |c| "dyno #{c.id}" }
			end

			def display_and_plot
				puts @results
#         @grapher.plot
			end

			def collect_stats t, stats
				[:enter_into_router_time, :enter_into_dyno_time, :beginning_of_processing_time, :exit_from_dyno_time, :dyno].each do |attr|
					stats[attr] = req.send attr
				end
				stats
			end

		end
	end
end



