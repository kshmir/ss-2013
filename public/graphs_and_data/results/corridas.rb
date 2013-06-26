params = {}
final_results = []

20.times do
	results = {}
	(30..70).to_a.each do |n|
		params[:input_variables] = {clients_limit: n, max_amount_of_iterations:n*100};
		algos = %w(RandomRouting RoundRobinRouting ShortestQueueRouting SmartRouting).map { |name| "Simulator::Strategy::Algorithm::#{name}".constantize }.map { |algo| Simulator::Strategy::LoadBalancer.with_algorithm algo, params };

		results[n] = {}
		algos.each { |algo| results[n][algo.algorithm.class.to_s] = Simulator::Core.simulate algo }
	end
	final_results << results
end
