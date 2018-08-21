class CreateLanguageUsers < ActiveRecord::Migration
  def change
    create_table :language_users do |t|
      t.references :language, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :language_users, [:language_id, :user_id], unique: true, name: 'index_language_user'
  end
end
