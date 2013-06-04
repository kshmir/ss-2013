module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
  	@sim = Simulation.find(sim_id)
		params = {}
    params[:input_variables] = { clients_limit: 3,
                                 max_amount_of_iterations: 100 }
    algorithm =     Simulator::Strategy::Algorithm::RandomRouting
  	load_balancer = Simulator::Strategy::LoadBalancer.with_algorithm algorithm, params
  	Simulator::Core.simulate load_balancer do |i, n, stats|
  		@sim.percentage = (i * 1.0 / n) * 100
  		@sim.content = [] unless @sim.content
  		@sim.content << stats
  		@sim.save
  	end
  end
end