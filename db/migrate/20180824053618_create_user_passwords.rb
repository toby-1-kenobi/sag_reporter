class CreateUserPasswords < ActiveRecord::Migration
  def change
    create_table :user_passwords do |t|
      t.integer :user_id, null: false
      t.string :password, null: false
      t.timestamps null: false
    end
  end
end
