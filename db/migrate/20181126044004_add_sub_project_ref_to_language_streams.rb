class AddSubProjectRefToLanguageStreams < ActiveRecord::Migration
  def change
    add_reference :language_streams, :sub_project, index: true, foreign_key: true
  end
end
