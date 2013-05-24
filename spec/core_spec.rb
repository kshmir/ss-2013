require 'pry'
require 'rspec_helper'

describe Simulator::Core do
  context "Calling the main simulator" do
    %w(RandomRouting RoundRobinRouting ShortestQueueRouting SmartRouting).each do |name|
      algorithm = "Simulator::Strategy::Algorithm::#{name}".constantize
      it "Should finish with no errors with algorithm #{name}" do
        load_balancer = init_load_balancer_with algorithm
        Simulator::Core.simulate load_balancer
      end
    end
  end
end