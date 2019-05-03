class MtResource < ActiveRecord::Base

  has_paper_trail

  include StateBased

  enum medium: {
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

  enum status: {
      unknown: 0,
      work_in_progress: 1,
      published: 2,
      completed_for_strategic_partners: 3
  }

  belongs_to :user
  belongs_to :language
  has_many :contributions, class_name: 'Creation', dependent: :destroy
  has_many :contributers, through: :contributions, source: 'person'
  has_and_belongs_to_many :product_categories, after_add: :update_self, after_remove: :update_self

  validates :name, presence: true
  validates :language, presence: true
  validates :cc_share_alike, presence: true
  validates :medium, presence: true
  validates :status, presence: true

  private

  def update_self _
    self.touch if self.persisted?
  end

end
