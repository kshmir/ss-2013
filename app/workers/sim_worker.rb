module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
  	@sim = Simulation.find(sim_id)
		params = {}
    params[:input_variables] = { clients_limit: @sim.clients,
                                 max_amount_of_iterations: @sim.iterations,
                                 reqs_per_second: @sim.reqs_per_second }

    if @sim.strategy == 'Random'
      algorithm = Simulator::Strategy::Algorithm::RandomRouting
    elsif @sim.strategy == 'Smart'
      algorithm = Simulator::Strategy::Algorithm::SmartRouting
    elsif @sim.strategy == 'Round Robin'
      algorithm = Simulator::Strategy::Algorithm::RoundRobinRouting
    else
      algorithm = Simulator::Strategy::Algorithm::ShortestQueueRouting
    end

  	load_balancer = Simulator::Strategy::LoadBalancer.with_algorithm algorithm, params
    data = []
  	Simulator::Core.simulate load_balancer do |i, n, stats, results|
      @sim.perc = (i * 1.0 / n) * 100
      stats.each do |st| @sim.stats << st end
      if results
        @sim.results = results
      end
    end
  end
end
