class Simulation < ActiveRecord::Base
  attr_accessible :ended_at, :created_at, :percentage

  serialize :content 
end