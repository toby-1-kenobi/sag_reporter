class TranslationProject < ActiveRecord::Base

  has_paper_trail

  belongs_to :language
  belongs_to :project
  has_many :translation_progresses, dependent: :destroy
  has_many :chapters, through: :translation_progresses
  has_many :translation_distributions, dependent: :destroy
  has_many :distribution_methods, through: :translation_distributions

  validates :language_id, presence: true
  validates :project_id, presence: true, uniqueness: {scope: :language_id}

  def count_verses(deliverable, first_month, last_month = nil)
    last_month ||= first_month
    translation_progresses.includes(:chapter).
        where(deliverable: deliverable).where('month BETWEEN ? AND ?', first_month, last_month).
        map{ |tp| tp.chapter.verses }.sum
  end

end
