class AllowNullForChurchMinistryInMinistryOutputs < ActiveRecord::Migration
  def change
    change_column_null :ministry_outputs, :church_ministry_id, true
  end
end
