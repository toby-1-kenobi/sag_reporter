class AddOutcomeAreaRefToMinistries < ActiveRecord::Migration
  def change
    add_reference :ministries, :topic, index: true, null: false, default: Topic.take.id
    add_foreign_key :ministries, :topics
  end
end
