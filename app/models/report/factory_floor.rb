module Report::FactoryFloor

  private

  def add_languages(language_ids)
    @instance.languages << Language.where(id: language_ids)
  end

  def add_topics(topic_ids)
    @instance.topics << Topic.where(id: topic_ids)
  end

  def add_pictures(pictures)
    pictures.values.each do |picture_attributes|
      debugger
      @instance.pictures.build(picture_attributes)
    end
  end

end