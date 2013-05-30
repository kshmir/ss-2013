module SimWorker
  @queue = :tasks
  def self.perform(sim_id)
    # Do anything here, like access models, etc
    puts "Doing my job"
  end
end