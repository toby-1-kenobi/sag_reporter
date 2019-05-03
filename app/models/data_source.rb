class DataSource < ActiveRecord::Base

  has_paper_trail

  has_many :languages, inverse_of: :pop_source, foreign_key: 'pop_source_id', dependent: :nullify
  validates :name, presence: true, allow_nil: false, uniqueness: true
end
