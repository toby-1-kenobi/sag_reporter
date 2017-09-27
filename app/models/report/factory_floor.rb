module Report::FactoryFloor

  private

  def add_languages(state_language_ids, geo_state_id)
    @instance.languages << Language.joins(:state_languages).where(:state_languages => { geo_state_id: geo_state_id, id: state_language_ids })
  end

  def add_observers(observers, geo_state_id, reporter)
    observers.values.each do |person_attributes|
      if person_attributes['name'].present?
        person_attributes.delete('id')
        person = Person.find_or_initialize_by person_attributes do |person|
          person.geo_state_id = geo_state_id
          person.record_creator = reporter
        end
      end
      if person and not @instance.observers.include? person
        @instance.observers << person
      end
    end
  end

  def add_external_picture(pictures_attributes)
    @tempfiles = Array.new
    result = Hash.new
    # convert image-strings to image-files
    pictures_attributes.each do |image_number, image_data|
      filename = "upload-image" + image_number
      tempfile = Tempfile.new(filename)
      tempfile.binmode
      tempfile.write Base64.decode64(image_data['created_external'])
      tempfile.rewind
      # for security we want the actual content type, not just what was passed in
      content_type = `file --mime -b #{tempfile.path}`.split(";")[0]

      # we will also add the extension ourselves based on the above
      # if it's not gif/jpeg/png, it will fail the validation in the upload model
      extension = content_type.match(/gif|jpg|jpeg|png/).to_s
      filename += ".#{extension}" if extension
      result[image_number] = Hash.new
      result[image_number][:ref] =
          ActionDispatch::Http::UploadedFile.new({
                                                     tempfile: tempfile,
                                                     type: content_type,
                                                     filename: filename
                                                 })
      @tempfiles.push tempfile
    end
    result
  end

  def cleanup_external_picture
    if @tempfiles
      @tempfiles.each do |tempfile|
        if tempfile
          tempfile.close
          tempfile.unlink
        end
      end
    end
  end

  def add_impact_attr(attr)
    @instance.impact_report.update_attribute('translation_impact', attr['translation_impact'])
  end

end