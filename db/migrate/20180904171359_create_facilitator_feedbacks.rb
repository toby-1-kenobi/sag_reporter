class CreateFacilitatorFeedbacks < ActiveRecord::Migration
  def change
    create_table :facilitator_feedbacks do |t|
      t.references :church_ministry, index: true, foreign_key: true, null: false
      t.string :month, null: false, index: true
      t.text :feedback, null: false
      t.references :team_member, index: true, null: true
      t.text :response, null: true

      t.timestamps null: false
    end
    add_foreign_key :facilitator_feedbacks, :users, column: :team_member_id
  end
end
