module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
  	@sim = Simulation.find(sim_id)
		params = {}
    params[:input_variables] = { clients_limit: 25,
                                 max_amount_of_iterations: 10 }
    algorithm =     Simulator::Strategy::Algorithm::RandomRouting
  	load_balancer = Simulator::Strategy::LoadBalancer.with_algorithm algorithm, params
    data = []
  	Simulator::Core.simulate load_balancer do |i, n, stats|
      @sim.percentage = (i * 1.0 / n) * 100
      stats.each do |st| @sim.stats << st end
      puts @sim.percentage
      @sim.save
    end
  end
end
