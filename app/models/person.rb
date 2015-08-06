class Person < ActiveRecord::Base

  belongs_to :language

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, length: { is: 10 }, allow_nil: true, numericality: true

  before_validation :fix_phone

    def fix_phone
      if self.phone
        # remove non digits from the phone number
        self.phone.gsub!(/[^0-9]/, '')
        # if it starts with "91" and is longer than 11 digits
        # then it's got a prefix we need to remove
        if self.phone.length > 11 and self.phone.start_with?("91")
          self.phone = self.phone.slice(2..-1)
        end
        # another prefix possibility is "0"
        if self.phone.length > 10 and self.phone.start_with?("0")
          self.phone = self.phone.slice(1..-1)
        end
      end
    end
end
