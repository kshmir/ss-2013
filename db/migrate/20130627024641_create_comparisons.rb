class CreateComparisons < ActiveRecord::Migration
  def change
    create_table :comparisons do |t|
      t.string :clients
      t.string :reqs_per_second
      t.string :strategies
      t.integer :iterations

      t.timestamps
    end
  end
end
