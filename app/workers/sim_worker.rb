module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
  	@sim = Simulation.find(sim_id)
  	100.times do
  		@sim.percentage = @sim.percentage + 1
  		@sim.save
  		sleep 1	
  	end
  end
end