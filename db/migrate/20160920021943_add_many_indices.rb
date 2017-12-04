class AddManyIndices < ActiveRecord::Migration
  def change
    add_index :events, :event_date
    add_index :geo_states, :name
    add_index :languages, :name
    add_index :mt_resources, :publish_year
    add_index :mt_resources, :created_at
    add_index :people, :name
    add_index :progress_markers, :weight
    add_index :progress_updates, :month
    add_index :progress_updates, :year
    add_index :reports, :report_date
    add_index :reports, :status
    add_index :state_languages, :project
    add_index :translatables, :identifier
    add_index :uploaded_files, :ref
    add_index :users, :name
    add_index :zones, :name
  end
end
