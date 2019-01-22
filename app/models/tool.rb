class Tool < ActiveRecord::Base

  has_paper_trail

  enum status: {
      active: 0,
      deleted: 1
  }

  belongs_to :creator, class_name: 'User'
  belongs_to :language
  has_and_belongs_to_many :product_categories, after_add: :update_self, after_remove: :update_self

  validates :url, presence: true
  validates :description, presence: true
  validates :language, presence: true
  validates :creator, presence: true

  private

  def update_self _
    self.touch if self.persisted?
  end

end
