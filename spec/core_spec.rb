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

describe Simulator::Strategy::Algorithm::RoundRobinRouting do
	context "Computing the next dyno to use" do

		before (:each) do
			@client1 = mock(Simulator::Strategy::LoadBalancer::Client)
			@client2 = mock(Simulator::Strategy::LoadBalancer::Client)
			@gen = Simulator::Strategy::Algorithm::RoundRobinRouting.new [@client1,@client2]
		end

		it "should return first dyno on first call if not full" do
			#these line are to fool the test done in Base.rb
			@client1.should_receive(:queue).and_return([nil])
			@client2.should_receive(:queue).and_return([nil])

			@client1.should_receive(:is_queue_full?).and_return(false)
			@client2.should_not_receive(:is_queue_full?)
			answer = @gen.compute
			answer.should equal(@client1)
		end

		it "should return second dyno if first is full" do
			@client1.should_receive(:queue).and_return([nil])
			@client2.should_receive(:queue).and_return([nil])

			@client1.should_receive(:is_queue_full?).and_return(true)
			@client2.should_receive(:is_queue_full?).and_return(false)
			answer = @gen.compute
			answer.should equal(@client2)
		end

		it "should return first dyno, then second, then first again" do
			@client1.should_receive(:queue).any_number_of_times.and_return([nil])
			@client2.should_receive(:queue).any_number_of_times.and_return([nil])

			@client1.should_receive(:is_queue_full?).twice.and_return(false)
			@client2.should_receive(:is_queue_full?).once.and_return(false)
			answer = @gen.compute
			answer.should equal(@client1)
			answer = @gen.compute
			answer.should equal(@client2)
			answer = @gen.compute
			answer.should equal(@client1)
		end

	end
end


