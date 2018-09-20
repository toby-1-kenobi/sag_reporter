class RelaxUniquenessConstraintInLanguageStreams < ActiveRecord::Migration
  def up
    remove_index :language_streams, name: "index_ministry_language_facilitator"
    add_index :language_streams,
              [:ministry_id, :state_language_id, :facilitator_id, :project_id],
              unique: true,
              name: "index_ministry_language_facilitator_project"
  end
  def down
    remove_index :language_streams, name: "index_ministry_language_facilitator_project"
    add_index :language_streams,
              [:ministry_id, :state_language_id, :facilitator_id],
              unique: true,
              name: "index_ministry_language_facilitator"
  end
end
