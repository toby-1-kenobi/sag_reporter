class Edit < ActiveRecord::Base

  enum status: {
      auto_approved: 0,
      pending_single_approval: 1,
      pending_double_approval: 2,
      pending_national_approval: 3,
      approved: 4,
      rejected: 5
  }

  belongs_to :user
  belongs_to :curated_by, class_name: 'User'
  has_and_belongs_to_many :geo_states

  validates :user, presence: true
  validates :model_klass_name, presence: true
  validates :record_id, presence: true
  validates :attribute_name, presence: true
  validates :old_value, presence: true, allow_blank: true
  validates :new_value, presence: true, allow_blank: true
  validates :status, inclusion: { in: statuses.keys }
  validate :record_id_exists
  validate :new_value_is_new

  after_save :set_geo_states

  scope :pending, -> { where(status: [statuses[:pending_single_approval], statuses[:pending_double_approval]]) }
  scope :for_curating, ->(user) { joins(:geo_states).where('geo_states.id' => user.curated_states) }

  # not including pending for national level approval.
  def pending?
    pending_single_approval? or pending_double_approval?
  end

  def applied?
    approved? or auto_approved?
  end

  def approve(curator)
    case
      when auto_approved?, approved?, rejected?
        return false
      when pending_double_approval?
        update_attributes(curated_by: curator, curation_date: Time.now)
        logger.debug "curaton date: #{curation_date} (#{curation_date.class})"
        pending_national_approval!
        if curator.national_curator?
          return approve(curator)
        end
        return true
      when pending_single_approval?, pending_national_approval?
        update_attributes(curated_by: curator, curation_date: Time.now) if pending_single_approval?
        update_attributes(second_curation_date: Time.now) if pending_national_approval?
        approved!
        # if apply fails it will change status to rejected and populate record_errors field
        return apply
    end
  end

  def apply
    thing_for_editing = model_klass_name.constantize.find(record_id)
    success = thing_for_editing.update_attributes(attribute_name => new_value)
    unless success
      update_attribute(:record_errors, thing_for_editing.errors.full_messages.to_sentence)
      rejected!
    end
    return success
  end

  def reject(curator)
    update_attributes(curated_by: curator, curation_date: Time.now)
    rejected!
  end

  private

  def record_id_exists
    begin
      errors.add(:record_id, "Could not find #{model_klass_name} with id #{record_id}") unless model_klass_name.constantize.find(record_id)
    rescue ActiveRecord::RecordNotFound => e
      errors.add(:record_id, e.message)
    end
  end

  def new_value_is_new
    errors.add(:new_value, 'must be different') if new_value == old_value
  end

  def set_geo_states
    geo_states.clear
    case model_klass_name
      when 'Language'
        geo_states << Language.find(record_id).geo_states
      else
        geo_states << user.geo_states
    end
  end

end
