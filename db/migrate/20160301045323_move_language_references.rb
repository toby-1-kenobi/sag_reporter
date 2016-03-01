class MoveLanguageReferences < ActiveRecord::Migration

  # This migration will fail silently if ImpactReports delegates :languages to Report.
  def up
    puts "This migration will do nothing if ImpactReports delegates :languages to Report."
    puts "are you sure you want to continue? [Y/n]"
    answer = $stdin.gets.chomp
    if answer != 'y' and answer != 'Y'
      fail "Make sure ImpactReports does not delegate :languages to Report, then try again."
    end
    ImpactReport.find_each do |ir|
      ir.report.languages << ir.languages
    end
  end

  def down
    puts "This migration will do nothing if ImpactReports delegates :languages to Report."
    puts "are you sure you want to continue? [Y/n]"
    answer = $stdin.gets.chomp
    if answer != 'y' and answer != 'Y'
      fail "Make sure ImpactReports does not delegate :languages to Report, then try again."
    end
    ImpactReport.find_each do |ir|
      ir.report.languages.clear
    end
  end

end
