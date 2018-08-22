class CreateRegistrationApprovals < ActiveRecord::Migration
  def change
    create_table :registration_approvals do |t|
      t.integer :registered_user, null: false, index: true
      t.integer :user_approve_registration, null: false, index: true

      t.timestamps null: false
    end
  end
end
