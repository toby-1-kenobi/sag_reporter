class CreatePhoneMessages < ActiveRecord::Migration
  def change
    create_table :phone_messages do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.text :content, null: false
      t.datetime :sent_at, index: true, null: true
      t.text :error_messages, null: true

      t.timestamps null: false
    end
  end
end
