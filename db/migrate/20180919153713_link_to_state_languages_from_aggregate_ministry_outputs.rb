class LinkToStateLanguagesFromAggregateMinistryOutputs < ActiveRecord::Migration
  def up
    remove_reference :aggregate_ministry_outputs, :language_stream
    add_reference :aggregate_ministry_outputs, :state_language, index: true, foreign_key: true, null: false
  end
  def down
    remove_reference :aggregate_ministry_outputs, :state_language
    add_reference :aggregate_ministry_outputs, :language_stream, index: true, foreign_key: true, null: false
  end
end
