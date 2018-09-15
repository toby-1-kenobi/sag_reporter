class AddFacilitatorPlanToFacilitatorFeedbacks < ActiveRecord::Migration
  def change
    add_column :facilitator_feedbacks, :facilitator_plan, :text, null: true
  end
end
