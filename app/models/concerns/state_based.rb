module StateBased

  extend ActiveSupport::Concern

  included do
    belongs_to :geo_state
    before_validation :geo_state_init
  end

  private

  def geo_state_init
    self.geo_state ||= record_creator.geo_state if respond_to? "record_creator" and record_creator
    self.geo_state ||= reporter.geo_state if respond_to? "reporter" and reporter
    self.geo_state ||= user.geo_state if respond_to? "user" and user
  end

end