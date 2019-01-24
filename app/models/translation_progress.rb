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

  validates :language, presence: true, uniqueness: { scope: [:chapter, :month, :deliverable_id] }
  validates :chapter, presence: true
  validates :month, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'" }

end
