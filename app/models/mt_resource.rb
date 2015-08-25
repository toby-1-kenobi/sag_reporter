class MtResource < ActiveRecord::Base

  include StateBased

  enum category: [ :song, :drama, :big_book, :flashcard, :tract, :story, :primer ]

  belongs_to :user
  belongs_to :language
  has_many :contributions, class_name: 'Creation', dependent: :destroy
  has_many :contributers, through: :contributions, source: "person"

end
