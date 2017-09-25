class MtResource < ActiveRecord::Base

  include StateBased

  enum category: {
      song: 0,
      drama: 1,
      big_book: 2,
      flashcard: 3,
      tract: 4,
      story: 5,
      primer: 6,
      dictionary: 7,
      jesus_film: 8,
      new_testament: 9,
      whole_bible: 10,
      bible_portion: 11,
      survey_report: 15,
      radio_program: 12,
      sunday_school_material: 13,
      other: 14
  }

  enum status: [ :unknown, :work_in_progress, :published ]

  belongs_to :user
  belongs_to :language
  has_many :contributions, class_name: 'Creation', dependent: :destroy
  has_many :contributers, through: :contributions, source: 'person'

end
