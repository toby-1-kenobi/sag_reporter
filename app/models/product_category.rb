class ProductCategory < ActiveRecord::Base
  has_and_belongs_to_many :mt_resources
  validates :number, presence: true, uniqueness: true
  
  belongs_to :name, class_name: 'TranslationCode', dependent: :destroy
  before_create :create_translation_codes

  def create_translation_codes
    self.name ||= TranslationCode.create
  end

  # allow getting the name with one method call like 'name_en' instead of 'name.en'
  def method_missing(method_id, *args)
    if match = matches_dynamic_locale_check?(method_id)
      name.send(match.captures.first)
    else
      super
    end
  end

  private

  def matches_dynamic_locale_check?(method_id)
    /\Aname_([a-z]{2})\z/.match(method_id.to_s)
  end

end
