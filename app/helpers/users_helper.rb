module UsersHelper

  # get a link to a user by name
  # don't mention the user name if the logged in user
  # doesn't have high-sensitivity access
  # assume there's a logged in user.
  def user_link(user)
    anchor_text = (logged_in_user.trusted? or logged_in_user?(user)) ? user.name : "user ##{user.id}"
    link_to anchor_text, user_path(user)
  end

  def reset_pwd_users
    User.where(:reset_password => true)
  end

  def send_pwd_reset_instructions(user, token)
    if user.email.present? and user.email_confirmed? and user.reset_password_token.present?
      logger.debug "sending password reset instructions to email: #{user.email}"
      UserMailer.reset_password_email(user, token).deliver_now
      true
    else
      logger.error "could not send password reset to: #{user.email}"
      false
    end
  end

  def filter_status(status)
    case status
    when 'approved'
      'active'
    when 'disabled'
      'disabled'
    else
      'pending'
    end
  end

end

