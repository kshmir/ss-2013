class AddFieldsToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :strategy, :string
    add_column :simulations, :clients, :integer
    add_column :simulations, :iterations, :integer
  end
end
