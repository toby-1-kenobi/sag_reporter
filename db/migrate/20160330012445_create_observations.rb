class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.references :report, index: true, foreign_key: true, null: false
      t.references :person, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :observations, [:report_id, :person_id], unique: true, name: 'index_reports_people'
  end
end
