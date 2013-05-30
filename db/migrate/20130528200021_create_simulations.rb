class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.datetime :ended_at
      t.text :content

      t.timestamps
    end
  end
end
