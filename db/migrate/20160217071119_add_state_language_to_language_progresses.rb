class AddStateLanguageToLanguageProgresses < ActiveRecord::Migration
  def change
    add_reference :language_progresses, :state_language, index: true, foreign_key: true
  end
end
