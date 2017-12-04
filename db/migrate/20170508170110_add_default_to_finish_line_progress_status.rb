class AddDefaultToFinishLineProgressStatus < ActiveRecord::Migration
  def change
    # status 1 should be not done but potential need
    change_column_default :finish_line_progresses, :status, 1
  end
end
