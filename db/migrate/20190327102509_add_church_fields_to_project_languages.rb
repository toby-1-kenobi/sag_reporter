class AddChurchFieldsToProjectLanguages < ActiveRecord::Migration
  def change
    add_column :project_languages, :churches_reported, :integer
    add_column :project_languages, :people_in_churches, :integer
    add_column :project_languages, :followup_contact, :text
  end
end
