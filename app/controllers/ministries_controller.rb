class MinistriesController < ApplicationController

  before_action :require_login

  def projects_overview
    @ministry = Ministry.find params[:id]
    @deliverables = @ministry.deliverables.where.not(reporter: 4).includes(short_form: :translations).
        map{ |d|  {
            id: d.id,
            short_form: d.short_form.send(logged_in_user.interface_language.locale_tag),
            reporter: d.reporter,
            calc_method: d.calculation_method
        } }
    state_languages = StateLanguage.includes(:geo_state).map{ |sl| [sl.id, sl.geo_state.zone_id] }
    @sl_by_zone = Hash.new(Array.new)
    state_languages.each{ |sl| @sl_by_zone[sl[1]] += [sl[0]] }
    church_ministries = ChurchMinistry.includes(church_team: {state_language: :geo_state}).map{ |cm| [cm.id, cm.church_team.state_language_id, cm.church_team.state_language.geo_state.zone_id] }
    @cm_to_sl = church_ministries.map{ |cm| cm.slice(0,2) }.to_h
    @cm_by_zone = Hash.new(Array.new)
    church_ministries.each{ |cm| @cm_by_zone[cm[2]] += [cm[0]] }
    @zones = Zone.all
    @quarter = params[:quarter]
    respond_to :js
  end

end
