class AddGeoStateReferenceToUser < ActiveRecord::Migration
  def change
    add_reference :users, :geo_state, index: true, foreign_key: true
  end
end
