module ContactDetails

  extend ActiveSupport::Concern

  included do

  	before_validation :fix_phone

    # Pretty-print phone number
    def pretty_phone
      self.phone.slice(0..3) + ' ' + self.phone.slice(4..6) + ' ' + self.phone.slice(7..-1)
    end

  end

  private

    def fix_phone
      if self.phone and phone.length > 0
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
      else
        self.phone = nil
      end
    end

end