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
    @user_info = User.where(:reset_password => true)
    @user_info
  end

  def send_otp_via_email(email)
    username = email

    if username.include? '@'
      # if the user has put something with an '@' in it is must be their email address
      @user = User.find_by(email: username)
    else
      # otherwise we'll assume it's their phone number
      @user = User.find_by(phone: username)
    end

    if @user.present?
      otp_code = @user.otp_code

      if @user.phone.present? and not @user.email_confirmed?
        @ticket =  send_otp_on_phone1("+91#{@user.phone}", otp_code)
        flash.now['info'] = "A short login code has been sent to your phone (#{@user.phone}). Please wait for it."
      elsif @user.phone.present? and send_otp_via_mail_forgot_pwd(@user, otp_code)
        flash.now['info'] = "A short login code has been sent to your email (#{@user.email}). Check your inbox."
       end
    else
      flash.now['error'] = 'username incorrect'
    end
  end

  def send_otp_via_mail_forgot_pwd(user, otp_code)
    if user.email.present? && user.email_confirmed?
      logger.debug "sending otp to email: #{user.email}, otp: #{otp_code}"
      UserMailer.user_otp_code(user, otp_code).deliver_now
      true
    else
      false
    end
  end
end

