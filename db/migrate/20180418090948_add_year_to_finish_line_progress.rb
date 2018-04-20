class AddYearToFinishLineProgress < ActiveRecord::Migration
  def change
    add_column :finish_line_progresses, :year, :integer,  :null => :true, :default => :null

    remove_index :finish_line_progresses, name: 'index_lang_finish_line'

    add_index :finish_line_progresses, [:language_id, :finish_line_marker_id, :year], unique: true, name: 'index_lang_finish_line'

  end
end
