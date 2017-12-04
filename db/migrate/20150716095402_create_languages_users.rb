class CreateLanguagesUsers < ActiveRecord::Migration
  def change
    create_table :languages_users, :id => false do |t|
      t.integer :user_id
      t.integer :language_id
    end
    add_index :languages_users, [:user_id, :language_id], unique: true
  end
end
