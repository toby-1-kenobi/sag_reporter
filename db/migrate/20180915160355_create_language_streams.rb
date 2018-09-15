class CreateLanguageStreams < ActiveRecord::Migration
  def change
    create_table :language_streams do |t|
      t.references :ministry, index: true, foreign_key: true, null: false
      t.references :state_language, index: true, foreign_key: true, null: false
      t.references :facilitator, index: true, null: true
      t.references :project, index: true, foreign_key: true, null: true

      t.timestamps null: false
    end
    add_foreign_key :language_streams, :users, column: :facilitator_id
    add_index :language_streams, [:ministry_id, :state_language_id, :facilitator_id], unique: true, name: 'index_ministry_language_facilitator'
  end
end
