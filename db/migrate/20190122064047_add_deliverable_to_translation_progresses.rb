class AddDeliverableToTranslationProgresses < ActiveRecord::Migration
  def change
    add_reference :translation_progresses, :deliverable, index: true, foreign_key: true, null: false
    add_column :translation_progresses, :translation_method, :integer, index: true, default: 0, null: false
    add_column :translation_progresses, :translation_tool, :integer, index: true, default: 0, null: false
    add_column :translation_progresses, :month, :string, index: true, null: true
    add_index :translation_progresses, [:month, :chapter_id, :language_id, :deliverable_id], unique: true, name: 'index_translation_progress_unique'
  end
end
