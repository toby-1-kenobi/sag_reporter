class SubProject < ActiveRecord::Base
  belongs_to :project
  validates :name, presence: true
  validates :project, presence: true, uniqueness: { scope: :name }
end
