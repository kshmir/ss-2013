class AlterSimulationToChangeRequestsPerSecondType < ActiveRecord::Migration
  def up
  	change_column :simulations, :reqs_per_second, :float
  end

  def down
  end
end
