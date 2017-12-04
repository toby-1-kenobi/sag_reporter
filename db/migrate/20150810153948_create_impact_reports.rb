class CreateImpactReports < ActiveRecord::Migration
  def change
    create_table :impact_reports do |t|
      t.text :content, null: false
      t.belongs_to :reporter, index: true, references: :users
      t.belongs_to :event, index: true, foreign_key: true
      t.boolean :mt_society
      t.boolean :mt_church
      t.boolean :needs_society
      t.boolean :needs_church
      t.belongs_to :progress_marker, index: true, foreign_key: true
      t.integer :state

      t.timestamps null: false
    end
    add_foreign_key :impact_reports, :users, column: :reporter_id
  end
end
