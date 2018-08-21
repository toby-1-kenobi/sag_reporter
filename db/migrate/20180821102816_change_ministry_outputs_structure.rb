class ChangeMinistryOutputsStructure < ActiveRecord::Migration
  def change
    remove_reference :ministry_outputs, :church_congregation, { index: true, foreign_key: true, null: false }
    add_reference :ministry_outputs, :church_ministry, index: true, foreign_key: true, null: false
  end
end
