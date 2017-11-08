# extract the year from the name of a data source
def get_source_year(source)
  year = source.name.scan(/\d{4}/).first
  year ? year.to_i : nil
end

# extract the name without the year from a data source
def get_source_name(source)
  source.name.gsub(/\d|\(.*\)/, '').strip
end

# migrate language population data into new backend structure Nov 2017
Language.includes(:pop_source).find_each do |lang|
  if lang.population_all_countries.present?
    pop = lang.populations.new(amount: lang.population_all_countries, international: true)
    if lang.pop_source and lang.population.blank?
      pop.year = get_source_year(lang.pop_source)
      pop.source = get_source_name(lang.pop_source)
    end
    pop.save
  end
  if lang.population.present?
    pop = lang.populations.new(amount: lang.population)
    if lang.pop_source
      pop.year = get_source_year(lang.pop_source)
      pop.source = get_source_name(lang.pop_source)
    end
    pop.save
  end
end