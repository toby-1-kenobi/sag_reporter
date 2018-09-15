class RemoveLanguageStreamFromChurchMinistries < ActiveRecord::Migration
  def up
    remove_reference :church_ministries, :language_stream
    add_reference :church_ministries, :facilitator, index: true, null: true
    add_foreign_key :church_ministries, :users, column: :facilitator_id
  end
  def down
    remove_reference :church_ministries, :facilitator
    add_reference :church_ministries, :language_stream, index: true, foreign_key: true, null: true
  end
end
