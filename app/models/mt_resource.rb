class MtResource < ActiveRecord::Base

  enum type: [ :song, :drama, :big_book, :flashcard, :tract, :story, :primer ]

  belongs_to :user
  belongs_to :language

end
