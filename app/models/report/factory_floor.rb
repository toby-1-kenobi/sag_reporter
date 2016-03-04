module Report::FactoryFloor

  private

  def add_languages(language_ids)
    @instance.languages << Language.where(id: language_ids)
  end

  def add_topics(topic_ids)
    @instance.topics << Topic.where(id: topic_ids)
  end

end