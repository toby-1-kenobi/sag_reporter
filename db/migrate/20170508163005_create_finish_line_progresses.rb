class CreateFinishLineProgresses < ActiveRecord::Migration
  def change
    create_table :finish_line_progresses do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :finish_line_marker, index: true, foreign_key: true, null: false
      t.integer :status, null:false

      t.timestamps null: false
    end
    add_index :finish_line_progresses, [:language_id, :finish_line_marker_id], unique: true, name: 'index_lang_finish_line'
  end
end
