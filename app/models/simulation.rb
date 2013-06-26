class Simulation < ActiveRecord::Base
	attr_accessible :ended_at, :created_at, 
									:percentage, :strategy, 
									:clients, :iterations, 
									:reqs_per_second

	serialize :content

	include Redis::Objects

	list :stats, marshal: true
end

