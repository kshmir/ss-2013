class AddAmountOfTestsToComparisons < ActiveRecord::Migration
  def change
    add_column :comparisons, :amount_of_tests, :integer
  end
end
