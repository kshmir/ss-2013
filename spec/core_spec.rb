require 'pry'
require 'spec_helper'

describe Simulator::Core do
  context "Calling the main simulator" do
#     %w(RandomRouting RoundRobinRouting ShortestQueueRouting SmartRouting).each do |name|
		%w(RandomRouting).each do |name|
			algorithm = "Simulator::Strategy::Algorithm::#{name}".constantize

			before (:each) do
				#         @arrival_times_generator = mock(Simulator::Strategy::RandomVariable)
				#         @exit_times_generator = mock(Simulator::Strategy::RandomVariable)
			end

			it "Should finish with no errors with algorithm #{name}" do
				results = []
				params = {}
				params[:input_variables] = { clients_limit: 75,
																 max_amount_of_iterations: 1000}
				#                                      next_arrival_time: @arrival_times_generator,
				#                                      next_exit_time: @exit_times_generator }
				load_balancer = init_load_balancer_with algorithm, params

				#         @arrival_times_generator.should_receive(:calculate).exactly(5).times.and_return(1,2,0.9,1,1)
				#         @exit_times_generator.should_receive(:calculate).exactly(5).times.and_return(1,1,4,4,4)

				Simulator::Core.simulate load_balancer do ||
				end
			end
		end
	end
end

# describe Simulator::Strategy::Algorithm::RoundRobinRouting do
#   context "Computing the next dyno to use" do

#     before (:each) do
#       @client1 = mock(Simulator::Strategy::RequestProcessor::Client)
#       @client2 = mock(Simulator::Strategy::RequestProcessor::Client)
#       @gen = Simulator::Strategy::Algorithm::RoundRobinRouting.new [@client1,@client2]
#     end

#     it "should return first dyno on first call if not full" do
#       @client1.should_receive(:is_queue_full?).any_number_of_times.and_return(false)
#       @client2.should_receive(:is_queue_full?).any_number_of_times.and_return(false)
#       answer = @gen.compute
#       answer.should equal(@client1)
#     end

#     it "should return second dyno if first is full" do
#       @client1.should_receive(:is_queue_full?).any_number_of_times.and_return(true)
#       @client2.should_receive(:is_queue_full?).any_number_of_times.and_return(false)
#       answer = @gen.compute
#       answer.should equal(@client2)
#     end

#     it "should return first dyno, then second, then first again" do
#       @client1.should_receive(:is_queue_full?).any_number_of_times.and_return(false)
#       @client2.should_receive(:is_queue_full?).any_number_of_times.and_return(false)
#       answer = @gen.compute
#       answer.should equal(@client1)
#       answer = @gen.compute
#       answer.should equal(@client2)
#       answer = @gen.compute
#       answer.should equal(@client1)
#     end

#   end
# end

# describe Simulator::Strategy::Algorithm::SmartRouting do
#   context "Computing the next dyno to use" do
#     before (:each) do
#       @clients = (1..5).map { mock(Simulator::Strategy::RequestProcessor::Client) }
#       @gen = Simulator::Strategy::Algorithm::SmartRouting.new @clients
#     end

#     it "should select the empty dyno" do
#       [0,1,2,4].each { |i| @clients[i].should_receive(:idle?).any_number_of_times.and_return(false) }
#       [0,1,2,4].each { |i| @clients[i].should_receive(:is_queue_full?).any_number_of_times.and_return(false) }

#       @clients[3].should_receive(:idle?).any_number_of_times.and_return(true)
#       @clients[3].should_receive(:is_queue_full?).any_number_of_times.and_return(false)

#       answer = @gen.compute
#       answer.should equal(@clients[3])
#     end

#     it "should not select any dyno as they are all busy" do
#       (0..4).each { |i| @clients[i].should_receive(:idle?).any_number_of_times.and_return(false) }
#       (0..4).each { |i| @clients[i].should_receive(:is_queue_full?).any_number_of_times.and_return(false) }

#       answer = @gen.compute
#       answer.should equal(nil)
#     end
#   end
# end


