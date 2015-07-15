class User < ActiveRecord::Base
  
  belongs_to :role
  has_many :permissions, through: :role

  attr_accessor :remember_token

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, presence: true, length: { is: 10 }, format: { with: /\A\d+\Z/ }, uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  before_validation :fix_phone

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Pretty print phone number
  def pretty_phone
    self.phone.slice(0..3) + ' ' + self.phone.slice(4..6) + ' ' + self.phone.slice(7..-1)
  end

  # allow method names such as is_a_ROLE1_or_ROLE2?
  # where ROLE1 and ROLE2 are the names of a valid roles
  # or can_PERM1_or_PERM2?
  # where PERM1 and PERM2 are the names of a valid permissions
  def method_missing(method_id, *args)
    if match = matches_dynamic_role_check?(method_id)
      tokenize(match.captures.first).each do |role_name|
        return true if role.name.downcase == role_name
      end
      return false
    elsif match = matches_dynamic_perm_check?(method_id)
      tokenize(match.captures.first).each do |perm_name|
         return true if permissions.find_by_name(perm_name)
      end
      return false
    else
      super
    end
  end

      private

      def tokenize(string_to_split)
        string_to_split.split(/_or_/)
      end

      def matches_dynamic_role_check?(method_id)
        /^is_an?_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
      end

      def matches_dynamic_perm_check?(method_id)
        /^can_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
      end

      def fix_phone
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
