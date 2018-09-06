class CreateChurchTeamMemberships < ActiveRecord::Migration
  def change
    create_table :church_team_memberships do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :church_team, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :church_team_memberships, [:user_id, :church_team_id], unique: true, name: 'index_church_team_user'
  end
end
