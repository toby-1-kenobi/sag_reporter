class AddChurchCongregationToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :church_congregation, index: true, foreign_key: true, null: true
  end
end
