class AddNumberToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :number, :integer, null: false, default: 0
  end
end
