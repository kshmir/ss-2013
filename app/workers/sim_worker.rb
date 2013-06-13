module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
  	@sim = Simulation.find(sim_id)
		params = {}
    params[:input_variables] = { clients_limit: 10,
                                 max_amount_of_iterations: 100 }
    algorithm =     Simulator::Strategy::Algorithm::RoundRobinRouting
  	load_balancer = Simulator::Strategy::LoadBalancer.with_algorithm algorithm, params
    data = []
  	Simulator::Core.simulate load_balancer do |i, n, stats| data << stats end
    data.map { |x| x[:queue_size] }
  end
end