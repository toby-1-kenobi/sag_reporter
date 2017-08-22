class AddTranslationImpactToImpactReports < ActiveRecord::Migration
  def change
    add_column :impact_reports, :translation_impact, :boolean, default: false, null: false
  end
end
