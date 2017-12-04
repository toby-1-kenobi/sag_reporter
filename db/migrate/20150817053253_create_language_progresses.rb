class CreateLanguageProgresses < ActiveRecord::Migration
  def change
    create_table :language_progresses do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :progress_marker, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :language_progresses, [:progress_marker_id, :language_id], unique: true
  end
end
