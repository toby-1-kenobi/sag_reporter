class AddStateLanguageIdToSupervisorFeedbacks < ActiveRecord::Migration
  def change
    add_reference :supervisor_feedbacks, :state_language, index: true, foreign_key: true
    add_index :supervisor_feedbacks, [:ministry_id, :state_language_id, :facilitator_id, :month], unique: true, name: 'index_supervisor_feedbacks_uniqueness'
  end
end
