module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in session for 20 minutes.
  def remember(user)
    user.remember
    cookies.signed[:user_id] = { value: user.id, expires: 20.minutes.from_now }
    cookies[:remember_token] = { value: user.remember_token, expires: 20.minutes.from_now }
  end

  # Returns the current logged-in user (if any).
  def logged_in_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def logged_in_user?(user)
    user == logged_in_user
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !logged_in_user.nil?
  end

  # Confirms a logged-in user.
  # and refreshes login timeout
  def require_login
    if logged_in?
      remember(logged_in_user)
      update_login_dt(logged_in_user)
    else
      flash['warning'] = 'Please log in.'
      respond_to do |format|
        format.html do
          store_location
          redirect_to login_url
        end
        format.js do
          render js: "window.location.replace('#{login_url}');"
        end
        format.pdf do
          redirect_to login_url
        end
        format.xlsx do
          redirect_to login_url
        end
      end
    end
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
  	forget(logged_in_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def current_user
    @current_user
  end

  #Update user last login date
  def update_login_dt(user)
    if user
      user.update_attribute(:user_last_login_dt, Date.today)
    end
  end
end
