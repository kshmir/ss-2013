module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
  	@sim = Simulation.find(sim_id)
		params = {}
    params[:input_variables] = { clients_limit: 20,
                                 max_amount_of_iterations: 20 }
    algorithm =     Simulator::Strategy::Algorithm::ShortestQueueRouting
  	load_balancer = Simulator::Strategy::LoadBalancer.with_algorithm algorithm, params
    data = []
  	Simulator::Core.simulate load_balancer do |i, n, stats, elected_clients|
      @sim.percentage = (i * 1.0 / n) * 100
      @sim.content = { current_clients: nil, stats: []} unless @sim.content
          @sim.content[:current_clients] = elected_clients
      @sim.content[:stats] << stats
      @sim.save
    end
  end
end