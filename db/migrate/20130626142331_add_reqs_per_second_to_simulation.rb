class AddReqsPerSecondToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :reqs_per_second, :integer
  end
end
