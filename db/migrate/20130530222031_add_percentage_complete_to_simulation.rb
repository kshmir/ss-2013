class AddPercentageCompleteToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :percentage, :float
  end
end
