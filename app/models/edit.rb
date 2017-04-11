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

  validates :user, presence: true
  validates :model_klass_name, presence: true
  validates :record_id, presence: true
  validates :attribute_name, presence: true
  validates :old_value, presence: true
  validates :new_value, presence: true
  validates :status, inclusion: { in: statuses.keys }
  validate :record_id_exists

  def geo_states
    case model_klass_name
      when 'Language'
        if language = Language.find(record_id)
          language.geo_states
        else
          logger.error "Edit #{id} has invalid record id!"
          return
        end
      else
        user.geo_states
    end
  end

  def approve
    case
      when auto_approved?, approved?, rejected?
        return false
      when pending_double_approval?
        pending_national_approval!
        return true
      when pending_single_approval?, pending_national_approval?
        thing_for_editing = model_klass_name.constantize.find(record_id)
        if thing_for_editing.update_attributes(attribute_name => new_value)
          approved!
          return true
        else
          logger.debug "could not approve edit"
          logger.debug thing_for_editing.errors.full_messages
        end
    end
  end

  private

  def record_id_exists
    begin
      model_klass_name.constantize.find(record_id)
    rescue ActiveRecord::RecordNotFound => e
      errors.add(:record_id, e.message)
    end

  end

end
