class CreateRegistrationApprovals < ActiveRecord::Migration
  def change
    create_table :registration_approvals do |t|
      t.references :registering_user, null: false, index: true
      t.references :approver, null: false, index: true

      t.timestamps null: false
    end
    add_foreign_key :registration_approvals, :users, column: :registering_user_id
    add_foreign_key :registration_approvals, :users, column: :approver_id
    add_index :registration_approvals, [:registering_user_id, :approver_id], unique: true, name: 'index_registering_user_approver'
  end
end
