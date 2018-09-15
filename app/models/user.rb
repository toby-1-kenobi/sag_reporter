class User < ActiveRecord::Base

  include ContactDetails

  enum training_level: {
    team_member: 1,
    facilitator: 2,
    project_supervisor: 4,
  }

  enum registration_status: {
      unapproved: 0,
      zone_approved: 1,
      approved: 2
  }


  has_many :reports, foreign_key: 'reporter_id', inverse_of: :reporter, dependent: :restrict_with_error
  has_many :events, inverse_of: :record_creator, dependent: :restrict_with_error
  has_many :people, inverse_of: :record_creator, dependent: :restrict_with_error
  has_many :progress_updates, dependent: :restrict_with_error
  belongs_to :mother_tongue, class_name: 'Language', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :spoken_languages, class_name: 'Language', after_add: :update_self, after_remove: :update_self
  has_and_belongs_to_many :geo_states, after_add: :update_self, after_remove: :update_self
  has_many :zones, through: :geo_states
  has_many :output_counts, dependent: :restrict_with_error
  belongs_to :interface_language, class_name: 'Language', foreign_key: 'interface_language_id'
  has_many :mt_resources, dependent: :nullify
  has_many :curatings, dependent: :destroy
  has_many :curated_states, through: :curatings, class_name: 'GeoState', source: 'geo_state', inverse_of: :curators
  has_many :edits, dependent: :destroy
  has_many :curated_edits, class_name: 'Edit', foreign_key: 'curated_by_id', inverse_of: :curated_by, dependent: :nullify
  has_many :external_devices
  has_many :championed_languages, class_name: 'Language', inverse_of: :champion, foreign_key: 'champion_id', dependent: :nullify,
           after_add: :update_self, after_remove: :update_self
  has_many :church_team_memberships, dependent: :destroy
  has_many :church_teams, through: :church_team_memberships
  has_many :user_benefits, dependent: :destroy
  has_many :app_benefits, through: :user_benefits
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  has_many :ministry_outputs, inverse_of: :creator, dependent: :restrict_with_error
  has_many :registration_approvals, foreign_key: 'registering_user_id', dependent: :destroy, inverse_of: :registering_user
  has_many :registration_approvers, through: :registration_approvals, class_name: 'User', source: :approver, inverse_of: :registering_users
  has_many :approved_registrations, class_name: 'RegistrationApproval', foreign_key: 'approver_id', dependent: :destroy, inverse_of: :approver
  has_many :registering_users, through: :approved_registrations, class_name: 'User', inverse_of: :registration_approvers
  has_many :registration_approved_zones, through: :registration_approvers, source: :zones
  has_many :facilitator_responses, class_name: 'FacilitatorFeedback', inverse_of: :team_member, dependent: :nullify
  has_many :language_streams, foreign_key: 'facilitator_id', inverse_of: :facilitator
  has_many :ministries, through: :language_streams
  has_many :state_languages, through: :language_streams
  has_many :project_streams, dependent: :restrict_with_error, inverse_of: :supervisor

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

  scope :in_zones, ->(zones) { joins(:geo_states).where('geo_states.zone_id' => zones).uniq }

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Return a token for password reset process and store the hash of the token
  def generate_pwd_reset_token
    token = User.new_token
    if update_attributes(reset_password_token: BCrypt::Password.create(token))
      return token
    else
      return false
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    ActiveRecord::Base.record_timestamps = false
    begin
      self.remember_token = User.new_token
      update_attribute(:remember_digest, User.digest(remember_token))
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    ActiveRecord::Base.record_timestamps = false
    begin
      update_attribute(:remember_digest, nil)
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end

  # Pretty print phone number
  def pretty_phone
    if phone.present?
      self.phone.slice(0..3) + ' ' + self.phone.slice(4..6) + ' ' + self.phone.slice(7..-1)
    else
      ''
    end
  end

  # The locale string for this user
  def locale
    if interface_language.present?
      interface_language.locale_tag
    else
      Language.interface_fallback.locale_tag
    end
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

  def can_future_plan?
    admin? or lci_board_member? or lci_agency_leader?
  end

  # find out if this user curates for a particular language
  def curates_for?(language)
    curated_states.where(id: language.geo_states.pluck(:id)).any?
  end

  def can_curate?(edit)
    national_curator? or
        curated_states.where(id: edit.geo_states).any? or
        (forward_planning_curator? and edit.pending_forward_planning_approval?)
  end


  # allow method names such as is_a_ROLE1_or_ROLE2?
  # where ROLE1 and ROLE2 are the names of a valid roles
  def method_missing(method_id, *args)
    if match = matches_dynamic_role_check?(method_id)
      tokenize(match.captures.first).each do |role_name|
        return admin? if role_name == 'admin' or role_name == 'administrator'
        return curator? if role_name == 'curator'
        return national_curator? if role_name == 'national_curator'
        return true if role_description.present? and role_name == role_description.parameterize('_')
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

  def update_self object
    self.touch if self.persisted?
  end

  # a user registration must first be approved by a zone admin
  # in each zone that the user is in, then it reaches the next level of approval
  # and it must be approved by an LCI board member
  # returns a hash with key :success indicating if it worked
  def registration_approval_step(approver)
    if unapproved?
      approval = registration_approvals.create(approver: approver)
      if approval.persisted?
        reload
        # check if we have zone approval in each of our zones
        remaining_zones = zones - registration_approved_zones
        # if we have covered all zones go to the next approval level
        if remaining_zones.empty?
          if registration_approvers.where(lci_board_member: true).any?
            approved!
          else
            zone_approved!
          end
        end
        return { success: true }
      else
        Rails.logger.error("unable to create a zonal registration approval for user #{id} from user #{approver.id} - #{approval.errors.full_messages}")
        return { success: false, error_message: "unable to approve this user! #{approval.errors.full_messages}" }
      end
    elsif zone_approved?
      if approver.lci_board_member? or approver.admin?
        if email.present?
          approved!
          # registration has gone through two human approval process
          # assume that email address is correct
          update_attribute(:email_confirmed, true)
          return { success: true }
        else
          return { success: false, error_message: 'Cannot approve a user with no email address' }
        end
      else
        Rails.logger.error "Unprivileged user id: #{approver.id} attempted to approve user registration id #{id}"
        return { success: false, error_message: 'You do not have permission to give final approval' }
      end
    else
      Rails.logger.error "User #{id} triggered registration_approval_step when registration_status is #{registration_status}"
      return { success: false, error_message: 'User was already approved' }
    end
  end

  private

  # Check if the email address has been updated and it is present
  # if so send an email to confirm their email address.
  def send_confirmation_email
    if self.email_changed? && self.email.present? && self.registration_status != 'unapproved'
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

  def interface_language_must_have_locale_tag
    if interface_language.present? and interface_language.locale_tag.blank?
      errors.add(:interface_language, 'must be a user interface language.')
    end
  end

end
