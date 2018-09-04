class AddReferencesToReports < ActiveRecord::Migration
  def change
    add_reference :reports, :project, index: true, foreign_key: true, null: true
    add_reference :reports, :church_ministry, index: true, foreign_key: true, null: true
  end
end
