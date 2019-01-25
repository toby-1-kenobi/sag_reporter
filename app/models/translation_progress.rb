class TranslationProgress < ActiveRecord::Base

  has_paper_trail

  enum translation_method: {
    written: 0,
    oral: 1
  }

  enum translation_tool: {
      paratext: 0,
      render: 1,
      other: 10
  }

  belongs_to :language
  belongs_to :chapter
  belongs_to :deliverable

  validates :language, presence: true
  validates :chapter, presence: true, uniqueness: { scope: [:language, :month, :deliverable_id] }
  validates :month, allow_nil: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'" }
  validates :deliverable, presence: true
  validate :deliverable_is_for_translation, if: Proc.new{ |tp| tp.deliverable.present? }

  private

  def deliverable_is_for_translation
    errors.add(:deliverble_id, 'must be for translation progress') unless deliverable.translation_progress?
  end

end
