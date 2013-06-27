class Simulation < ActiveRecord::Base
	include Redis::Objects
	attr_accessible :ended_at, :created_at, 
									:strategy, 
									:clients, :iterations, 
									:reqs_per_second, :hidden

	serialize :content

	value :perc
	
	def percentage
		perc.value
	end

	list :stats, marshal: true
	value :stats_json

	value :results, marshal: true

	def json
		stats_json ||= stats.to_json
	end
end

