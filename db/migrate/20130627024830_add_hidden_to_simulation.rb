class AddHiddenToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :hidden, :boolean, default: false
  end
end
