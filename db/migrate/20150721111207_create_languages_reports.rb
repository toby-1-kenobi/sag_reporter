class CreateLanguagesReports < ActiveRecord::Migration
  def change
    create_table :languages_reports, :id => false do |t|
      t.integer :report_id
      t.integer :language_id
    end
    add_index :languages_reports, [:report_id, :language_id], unique: true
  end
end
