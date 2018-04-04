class AddprojectIdToLanguages < ActiveRecord::Migration
  def change
    add_reference :languages, :project, index: true, null: true
    add_foreign_key :languages, :projects
  end
end
