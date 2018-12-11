class ProductCategory < ActiveRecord::Base
  has_and_belongs_to_many :mt_resources
  validates :number, presence: true, uniqueness: true
  
  belongs_to :name, class_name: 'TranslationCode', dependent: :destroy
  before_create :create_translation_codes

  def create_translation_codes
    self.name ||= TranslationCode.create
  end

end
