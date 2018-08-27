class CombineYearAndMonthInMinistryOutputs < ActiveRecord::Migration
  def up
    change_column :ministry_outputs, :month, :string
    remove_column :ministry_outputs, :year
  end
  def down
    change_column :ministry_outputs, :month, :integer
    add_column :ministry_outputs, :year, :integer, index: true, null:false
  end
end
