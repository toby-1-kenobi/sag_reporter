class CreateProjectProgresses < ActiveRecord::Migration
  def change
    create_table :project_progresses do |t|
      t.references :project_stream, index: true, foreign_key: true, null: false
      t.string :month, index: true, null: false
      t.integer :progress
      t.text :comment
      t.boolean :approved, null: false, default: false

      t.timestamps null: false
    end
  end
end
