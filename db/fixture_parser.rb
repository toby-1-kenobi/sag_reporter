# Parse fixture files to seed the database in a non-destructive way
# duplicates are avoided and you may specify if the fields of an
# existing record should be updated.

module FixtureParser

  require 'yaml'

  # files_options_hash has fixtures file names as keys and then a has like this as values
  # {
  #  model_name: 'Permission',
  #  key_field: 'name' # this field defines the record - if it's the same it should be the same record
  #  update?: true # perform an update on existing records or only add new ones
  # }

  def parse_fixtures(files_options_hash)

  	# load the data from the files
  	fixtures = Hash.new
  	files_options_hash.each_key do |filename|
  	  fixtures[filename] = YAML.load(ERB.new(File.read(filename)).result)
  	end
  	#puts "all fixtures " + fixtures.inspect 

  	# before updating collect all the objects by names given in fixtures
  	all_objects = Hash.new
  	# and remember which need to be updated with their hash
  	to_update = Hash.new

  	# for each fixture file
  	fixtures.each do |filename, fixtures_hash|
  	  model_class = files_options_hash[filename][:model_name].classify.constantize
  	  key_field = files_options_hash[filename][:key_field]

  	  #for each fixture within the file
  	  fixtures_hash.each do |fixture, values_hash|
  	  	if files_options_hash[filename][:update?]
  	  	  # if we doing updates get or initialise it and apply the values then save
  	  	  model_instance = model_class.find_or_initialize_by(key_field => values_hash[key_field])
  	  	  all_objects[fixture] = model_instance
  	  	  to_update[fixture] = values_hash
  	  	else
  	  	  # if we're not updating check if it's there and add it if it's not
  	  	  model_instance = model_class.find_by(key_field => values_hash[key_field])
  	  	  if !model_instance
  	  	  	model_instance = model_class.new
  	  	  	to_update[fixture] = values_hash
  	  	  end
  	  	  all_objects[fixture] = model_instance
  	  	end
  	  end
  	end

  	# now we've collected all the models we can update the ones that need updating
  	to_update.each do |fixture_name, values_hash|
  	  update_model_instance(all_objects[fixture_name], values_hash, all_objects)
  	end

  end

  # Update a model instance with values from a fixture.
  # Some values may refer to other fixtures
  def update_model_instance(model_instance, values_hash, all_fixture_instances)

  	values_hash.each do |field, value|
  	  # if the field is an array we need to assign with 'push' instead of '='
  	  if model_instance.send(field).respond_to?("push") then push = true end
      # it may be a comma seperated list, so split it
      if value.respond_to?('split')
        values_array = value.split(',').map(&:strip)
      else
      	values_array = [value]
      end
      values_array.each do |value|
      	# if it refers to another fixture use the corresponding object as the value
  	    if fixt = all_fixture_instances[value] and fixt != model_instance
  	      if push
  	      	model_instance.send(field).push(fixt)
  	      else
  	      	model_instance.send(field + '=', fixt)
  	      end
  	    else
  	      if push
  	      	model_instance.send(field).push(value)
  	      else
  	      	model_instance.send(field + '=', value)
  	      end
  	  	end
  	  end
  	end

  	model_instance.save!

  end

end