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

  after_save :set_geo_states

  def approve(curator)
    case
      when auto_approved?, approved?, rejected?
        return false
      when pending_double_approval?
        update_attributes(curated_by: curator, curation_date: Time.now)
        logger.debug "curaton date: #{curation_date} (#{curation_date.class})"
        pending_national_approval!
        return true
      when pending_single_approval?, pending_national_approval?
        thing_for_editing = model_klass_name.constantize.find(record_id)
        update_attributes(curated_by: curator, curation_date: Time.now) if pending_single_approval?
        update_attributes(second_curation_date: Time.now) if pending_national_approval?
        if thing_for_editing.update_attributes(attribute_name => new_value)
          approved!
          return true
        else
          rejected!
          logger.debug thing_for_editing.errors.full_messages.to_sentence
          update_attribute(:record_errors, thing_for_editing.errors.full_messages.to_sentence)
          return false
        end
    end
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
