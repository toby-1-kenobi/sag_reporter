class CreateReportsTopics < ActiveRecord::Migration
  def change
    create_table :reports_topics, :id => false do |t|
      t.integer :report_id
      t.integer :topic_id
    end
    add_index :reports_topics, [:report_id, :topic_id], unique: true
  end
end
