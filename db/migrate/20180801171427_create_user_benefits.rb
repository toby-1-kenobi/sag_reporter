class CreateUserBenefits < ActiveRecord::Migration
  def change
    create_table :user_benefits do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :app_benefit, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :user_benefits, [:user_id, :app_benefit_id], unique: true, name: 'index_user_benefit'
  end
end
