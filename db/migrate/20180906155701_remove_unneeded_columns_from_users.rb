class RemoveUnneededColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :facilitator, :boolean, index: true, null: false, default: false
    remove_reference :users, :church_team, index: true, foreign_key: true
  end
end
