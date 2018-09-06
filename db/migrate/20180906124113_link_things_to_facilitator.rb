class LinkThingsToFacilitator < ActiveRecord::Migration
  def up

    remove_index :ministry_workers, name: 'index_ministry_worker'
    remove_foreign_key :ministry_workers, column: :worker_id
    remove_reference :ministry_workers, :worker
    rename_table :ministry_workers, :facilitator_streams
    add_reference :facilitator_streams, :facilitator, index: true, foreign_key: true, null: false
    add_index :facilitator_streams, [:ministry_id, :facilitator_id], unique: true, name: 'index_facilitator_ministry'

    remove_index :language_users, name: 'index_language_user'
    remove_reference :language_users, :user
    rename_table :language_users, :facilitator_languages
    add_reference :facilitator_languages, :facilitator, index: true, foreign_key: true, null: false
    add_index :facilitator_languages, [:language_id, :facilitator_id], unique: true, name: 'index_language_facilitator'

    add_reference :church_ministries, :facilitator, index: true, foreign_key: true, null: false

  end

  def down
    remove_reference :church_ministries, :facilitator
    remove_index :facilitator_languages, name: 'index_language_facilitator'
    remove_reference :facilitator_languages, :facilitator
    rename_table :facilitator_languages, :language_users
    add_reference :language_users, :user, index: true, foreign_key: true, null: false
    add_index :language_users, [:language_id, :user_id], unique: true, name: 'index_language_user'
    remove_index :facilitator_streams, name: 'index_facilitator_ministry'
    remove_reference :facilitator_streams, :facilitator
    rename_table :facilitator_streams, :ministry_workers
    add_reference :ministry_workers, :worker, index: true, null: false
    add_foreign_key :ministry_workers, :users, column: :worker_id
    add_index :ministry_workers, [:ministry_id, :worker_id], unique: true, name: 'index_ministry_worker'
  end
end
