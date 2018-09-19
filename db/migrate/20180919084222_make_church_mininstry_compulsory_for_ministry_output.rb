class MakeChurchMininstryCompulsoryForMinistryOutput < ActiveRecord::Migration
  def change
    change_column_null :ministry_outputs, :church_ministry_id, false
    remove_column :deliverables, :for_facilitator, :boolean, null: false, default: false
  end
end
