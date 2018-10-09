class AddExpirationToPhoneMessages < ActiveRecord::Migration
  def change
    add_column :phone_messages, :expiration, :datetime, index: true, null: true
  end
end
