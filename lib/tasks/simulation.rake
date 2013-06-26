namespace :simulation do
  desc "Runs a set of simulations changing the values of a given parameter and outputs results"
  task :with_parameters=> :environment do
		params = {}
		results = {}
		clients_limits = ENV["clients_limit"].split(/,/).map { |n| n.to_i }
		reqs_per_sec   = ENV["reqs_per_second"].split(/,/).map { |n| n.to_i }

		clients_limits.each do |clients|
			results[clients] = {}
			reqs_per_sec.each do |reqs|
				params[:input_variables] = {clients_limit: clients, max_amount_of_iterations: ENV["iterations"], reqs_per_second: reqs};
				algo = "Simulator::Strategy::Algorithm::#{ENV["algorithme"]}".constantize
				s = Simulator::Strategy::LoadBalancer.with_algorithm algo, params

				results[clients][reqs] = Simulator::Core.simulate s
			end
		end
		results
	end
end

