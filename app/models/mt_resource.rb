class MtResource < ActiveRecord::Base

  include StateBased

  enum category: [
      :song,
      :drama,
      :big_book,
      :flashcard,
      :tract,
      :story,
      :primer,
      :dictionary,
      :jesus_film,
      :new_testament,
      :whole_bible,
      :bible_portion,
      :radio_program,
      :sunday_school_material,
      :other ]

  enum status: [ :unknown, :work_in_progress, :published ]

  belongs_to :user
  belongs_to :language
  has_many :contributions, class_name: 'Creation', dependent: :destroy
  has_many :contributers, through: :contributions, source: 'person'

end
