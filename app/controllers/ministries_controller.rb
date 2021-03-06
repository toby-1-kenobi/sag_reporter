class MinistriesController < ApplicationController

  before_action :require_login

  def projects_overview
    @ministry = Ministry.find params[:id]
    @deliverables = @ministry.deliverables.active.includes(short_form: :translations).order(:ui_order).
        map{ |d|  {
            id: d.id,
            short_form: d.short_form.send(logged_in_user.interface_language.locale_tag),
            reporter: d.reporter,
            calc_method: d.calculation_method
        } }
    state_languages = StateLanguage.includes(:geo_state).map{ |sl| [sl.id, sl.geo_state.zone_id, sl.language_id, sl.primary] }
    @sl_by_zone = Hash.new(Array.new)
    state_languages.each{ |sl| @sl_by_zone[sl[1]] += [sl[0]] }
    church_ministries = ChurchMinistry.active.includes(church_team: {state_language: :geo_state}).pluck :id, :state_language_id, :zone_id
    @cm_to_sl = church_ministries.map{ |cm| cm.slice(0,2) }.to_h
    @cm_by_zone = Hash.new(Array.new)
    church_ministries.each{ |cm| @cm_by_zone[cm[2]] += [cm[0]] }
    @l_by_zone = Hash.new(Array.new)
    state_languages.select{ |sl| sl[3] }.each{ |sl| @l_by_zone[sl[1]] += [sl[2]] }
    @zones = Zone.all
    @quarter = params[:quarter]
    respond_to :js
  end

end
