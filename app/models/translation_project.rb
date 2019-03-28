class TranslationProject < ActiveRecord::Base

  belongs_to :language
  belongs_to :project
  has_many :translation_progresses, dependent: :destroy
  has_many :translation_distributions, dependent: :destroy
  has_many :distribution_methods, through: :translation_distributions

  validates :language_id, presence: true
  validates :project_id, presence: true, uniqueness: {scope: :language_id}

  def count_verses(deliverable, month)
    translation_progresses.includes(:chapter).where(month: month, deliverable: deliverable).
        map{ |tp| tp.chapter.verses }.sum
  end

end
