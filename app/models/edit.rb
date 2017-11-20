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
  validate :user_has_permission
  validate :new_related_record_exists

  after_save :set_geo_states

  scope :pending, -> { where(status: [statuses[:pending_single_approval], statuses[:pending_double_approval]]) }
  scope :for_curating, ->(user) { joins(:geo_states).where('geo_states.id' => user.curated_states) }


  @@removal_code = 'REMOVE_THIS_ENTITY'
  def self.removal_code
    @@removal_code
  end

  @@addition_code = 'ADD_THIS_ENTITY'
  def self.addition_code
    @@addition_code
  end

  # not including pending for national level approval.
  def pending?
    pending_single_approval? or pending_double_approval?
  end

  def applied?
    approved? or auto_approved?
  end

  def human_new_value
    column = model_klass_name.constantize.columns_hash[attribute_name]
    if column and column.type == :boolean
      new_value == '0' or new_value == 'false' ? 'No' : 'Yes'
    else
      new_value.humanize
    end
  end

  def human_old_value
    column = model_klass_name.constantize.columns_hash[attribute_name]
    if column and column.type == :boolean
      old_value == '0' or old_value == 'false' ? 'No' : 'Yes'
    else
      old_value.humanize
    end
  end

  def object_under_edition
    model_klass = model_klass_name.constantize
    model_klass.find(record_id)
  end

  def related_object(data)
    model_klass = model_klass_name.constantize
    assoc_klass = model_klass.reflect_on_association(attribute_name).klass
    # data is a string, but we must determine whether the contents of the string are a number or a hash
    if data.scan(/\D/).empty?
      # we've got an id for an existing record
      assoc_klass.find data
    else
      # we've got a hash of attributes for a new record
      assoc_klass.new(eval(data))
    end
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
    if relationship?
      case
        when new_value == Edit.removal_code
          success = object_under_edition.send(attribute_name).delete(old_value)
        when old_value == Edit.addition_code
          begin
            object_to_add = related_object(new_value)
            object_to_add.save unless object_to_add.persisted?
            if object_under_edition.send(attribute_name).include? object_to_add
              # we can't add this object to this association, because it's already there
              # report success without doing anything
              success = true
            else
              success = object_under_edition.send(attribute_name).send(:<<, object_to_add)
            end
          rescue ActiveRecord::RecordNotFound
            success = false
          end
        else
          # check the thing we're about to relate it to currently exists
          begin
            success = object_under_edition.update_attributes(attribute_name => related_object(new_value))
          rescue ActiveRecord::RecordNotFound
            success = false
          end
      end
    else
      success = object_under_edition.update_attributes(attribute_name => new_value)
    end
    unless success
      if object_under_edition.errors.any?
        update_attribute(:record_errors, object_under_edition.errors.full_messages.to_sentence)
      else
        update_attribute(:record_errors, 'An unknown error prevented this edit from being applied')
      end
      rejected!
    end
    return success
  end

  def reject(curator)
    update_attributes(curated_by: curator, curation_date: Time.now)
    rejected!
  end

  def self.prompt_curators
    cutoff = 7.days.ago
    # get all edits that have been waiting for approval for at least a week
    edits = Edit.pending.where('created_at < ?', cutoff)
    # for each edit mail the curators
    edits.each do |edit|
      curators = User.curating(edit).where('curator_prompted IS NULL OR curator_prompted < ?', cutoff).where.not(email: nil)
      curators.each do |curator|
        UserMailer.prompt_curator(curator).deliver_now
        curator.curator_prompted = DateTime.current
        curator.save
      end
    end
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

  def user_has_permission
    # national user has permission
    return if user.national?
    # if there's no intersect between the user's states and the states for this edit then they don't have permission
    if user.geo_states.where(id: get_geo_states.pluck(:id)).empty?
      errors.add(:user, 'does not have permission to edit this')
    end
  end

  def new_related_record_exists
    if relationship? and new_value != Edit.removal_code and new_value.is_a? Integer
      errors.add(:new_value, 'related object not found') unless related_object(new_value)
    end
  end

  def set_geo_states
    geo_states.clear
    geo_states << get_geo_states
  end

  def get_geo_states
    case model_klass_name
      when 'Language'
        Language.find(record_id).geo_states
      when 'FinishLineProgress'
        FinishLineProgress.find(record_id).language.geo_states
      else
        user.geo_states
    end
  end

end
