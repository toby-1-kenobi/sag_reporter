class UserMailerPreview < ActionMailer::Preview

  def prompt_champion
    language1 = Language.find_or_create_by(name: 'Test language 1')
    language2 = Language.find_or_create_by(name: 'Test language 2')
    UserMailer.prompt_champion(User.first, [[language1, 32.days.ago], [language2, 28.days.ago]])
  end

  def prompt_champion_single
    language1 = Language.find_or_create_by(name: 'Test language')
    UserMailer.prompt_champion(User.first, [[language1, 32.days.ago]])
  end

  def prompt_curator
    UserMailer.prompt_curator(User.find 1)
  end

end