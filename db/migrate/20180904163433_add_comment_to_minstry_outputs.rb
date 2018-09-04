class AddCommentToMinstryOutputs < ActiveRecord::Migration
  def change
    add_column :ministry_outputs, :comment, :text
  end
end
