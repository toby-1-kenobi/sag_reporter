class CreateFacilitators < ActiveRecord::Migration
  def change
    create_table :facilitators do |t|
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    create_table :facilitator_streams do |t|
      t.references :ministry, index: true, foreign_key: true, null: false
      t.references :facilitator, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :facilitator_streams, [:ministry_id, :facilitator_id], unique: true, name: 'index_facilitator_ministry'
    create_table :facilitator_languages do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :facilitator, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :facilitator_languages, [:language_id, :facilitator_id], unique: true, name: 'index_language_facilitator'
  end
end
