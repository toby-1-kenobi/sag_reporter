class User < ActiveRecord::Base

  include ContactDetails

  belongs_to :role
  has_many :reports, foreign_key: 'reporter_id', inverse_of: :reporter, dependent: :restrict_with_error
  has_many :events, inverse_of: :record_creator, dependent: :restrict_with_error
  has_many :people, inverse_of: :record_creator, dependent: :restrict_with_error
  has_many :progress_updates, dependent: :restrict_with_error
  belongs_to :mother_tongue, class_name: 'Language', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :spoken_languages, class_name: 'Language'
  has_many :tally_updates
  has_and_belongs_to_many :geo_states
  delegate :zone, to: :geo_state, allow_nil: true
  has_many :output_counts, dependent: :restrict_with_error
  belongs_to :interface_language, class_name: 'Language', foreign_key: 'interface_language_id'
  has_many :mt_resources, dependent: :restrict_with_error
  has_many :curatings, dependent: :destroy
  has_many :curated_states, through: :curatings, class_name: 'GeoState', source: 'geo_state', inverse_of: :curators
  has_many :edits, dependent: :destroy
  has_many :curated_edits, class_name: 'Edit', foreign_key: 'curated_by_id', inverse_of: :curated_by, dependent: :nullify

  attr_accessor :remember_token

  has_secure_password
  has_one_time_password

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone,
            presence: { if: -> { email.blank? } },
            allow_nil: true,
            length: { is: 10 },
            format: { with: /\A\d+\Z/ },
            uniqueness: true
  validates :password,
            presence: true,
            length: { minimum: 6 },
            format: {
                with: /\A[\d\w ]+\Z/im,
                message: 'must use only letters, numbers and spaces'
            },
            allow_nil: true
  validates :mother_tongue_id, presence: true, allow_nil: false
  validates :geo_states, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, length: { maximum: 255 },
            allow_blank: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :trusted, inclusion: [true, false]
  validates :national, inclusion: [true, false]
  validates :admin, inclusion: [true, false]
  validates :national_curator, inclusion: [true, false]
  validate :interface_language_must_have_locale_tag

  after_save :send_confirmation_email

  scope :curating, ->(edit) { joins(:curated_states).where('geo_states.id' => edit.geo_states) }

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
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
    if phone.present?
      self.phone.slice(0..3) + ' ' + self.phone.slice(4..6) + ' ' + self.phone.slice(7..-1)
    else
      ''
    end
  end

  # Transitional method
  #TODO: make sure nothing uses this, then remove it
  def geo_state
    geo_states.take
  end

  # The locale string for this user
  def locale
    if interface_language.present?
      interface_language.locale_tag
    else
      Language.interface_fallback.locale_tag
    end
  end

  def zones
    Zone.of_states geo_states
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end
  
  # If this user is in a zone that requires alternate pm descriptions return true
  def sees_alternate_pm_descriptions?
    zones.inject(false) { |alt_required, zone| alt_required || zone.pm_description_type == 'alternate' }
  end

  def sees_faith_based_data?
    !sees_alternate_pm_descriptions?
  end

  # find out if this user curates for a particular language
  def curates_for?(language)
    curated_states.where(id: language.geo_states.pluck(:id)).any?
  end

  # This is a transitional method for moving from using roles and permissions
  # to using the simplified fields on the user model for user level access.
  # it maps the permission names to the right values of the fields
  #TODO: stop using this transitional method
  def can?(permission)
    case permission
      when 'create_user', 'delete_user'
        admin?
      when 'edit_user'
        # not including self
        admin?
      when 'view_all_users'
        admin?
      when 'view_roles', 'edit_role', 'create_role'
        # not used any more
        false
      when 'view_all_languages'
        national?
      when 'create_language'
        national_curator?
      when 'edit_language'
        curator?
      when 'create_topic', 'edit_topic'
        admin?
      when 'view_all_topics'
        true
      when 'view_all_reports'
        national?
      when 'create_report', 'tag_report'
        true
      when 'edit_report', 'archive_report'
        admin?
      when 'evaluate_progress', 'view_outcome_totals'
        true
      when 'create_tally', 'view_all_tallies', 'edit_tally', 'archive_tally', 'increase_tally'
        # not used any more
        false
      when 'create_event', 'edit_event'
        true
      when 'view_all_people'
        trusted?
      when 'edit_person'
        trusted?
      when 'report_numbers', 'view_output_totals'
        true
      when 'add_resource', 'edit_resource','view_all_resources'
        true
      else
        logger.error("unknown permission: #{permission}")
        false
    end
  end


  # allow method names such as is_a_ROLE1_or_ROLE2?
  # where ROLE1 and ROLE2 are the names of a valid roles
  # or can_PERM1_or_PERM2?
  # where PERM1 and PERM2 are the names of a valid permissions
  def method_missing(method_id, *args)
    if match = matches_dynamic_role_check?(method_id)
      tokenize(match.captures.first).each do |role_name|
        return admin? if role_name == 'admin' or role_name == 'administrator'
        return curator? if role_name == 'curator'
        return national_curator? if role_name == 'national_curator'
        return true if role_description.present? and role_name == role_description.parameterize('_')
      end
      return false
    elsif match = matches_dynamic_perm_check?(method_id)
      tokenize(match.captures.first).each do |perm_name|
         return true if can?(perm_name)
      end
      return false
    else
      super
    end
  end

  def respond_to_missing?(method, *)
    method =~ /\Ais_an?_([a-zA-Z]\w*)\?\z/ || method =~ /\Acan_([a-zA-Z]\w*)\?\z/ || super
  end

  def resend_email_token
    logger.debug 'resending email verification email'
    UserMailer.user_email_confirmation(self).deliver_now
  end

  private

  # Check if the email address has been updated and it is present
  # if so send an email to confirm their email address.
  def send_confirmation_email
    if self.email_changed? && self.email.present?
      self.update_columns(
          confirm_token: SecureRandom.urlsafe_base64.to_s,
          email_confirmed: false
      )
      logger.debug 'sending email verification email'
      UserMailer.user_email_confirmation(self).deliver_now
    end
  end

  def tokenize(string_to_split)
    string_to_split.split(/_or_/)
  end

  def matches_dynamic_role_check?(method_id)
    /\Ais_an?_([a-zA-Z]\w*)\?\z/.match(method_id.to_s)
  end

  def matches_dynamic_perm_check?(method_id)
    /\Acan_([a-zA-Z]\w*)\?\z/.match(method_id.to_s)
  end

  def interface_language_must_have_locale_tag
    if interface_language.present? and interface_language.locale_tag.blank?
      errors.add(:interface_language, 'must be a user interface language.')
    end
  end

end
