ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'simplecov'
require 'minitest/reporters'
require 'minitest/rails/capybara'
require 'mocha/mini_test'
#require 'capybara/poltergeist'

SimpleCov.start 'rails'

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
	
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

module IntegrationHelper

  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    post two_factor_auth_path, session: { phone:    	   user.phone,
		                                   		password:	     password}
    post login_path, session: 					{ phone:   		   user.phone,
		                            					password:    	 password,
				 											  					otp_code:		   user.otp_code}
	end
end

Capybara.asset_host = "http://local host:3000"
