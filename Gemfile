source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Materialize for Google's Material Design layout
gem 'materialize-sass'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Turbolinks also breaks jQuery('document').ready. This fixes it.
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Populate db with multiple entities
gem 'faker'

# Pagination helper
gem 'will_paginate', '~> 3.0.6'

# group dates by periods
gem 'groupdate'

# create charts
gem 'chartkick'

# Use PostgreSQL as the database for Active Record
gem 'pg'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # For creating test-doubles
  gem 'mocha', require: false

  # For high level specification of integration tests
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
end

group :test do
  # For colouring test results red and green
  gem 'minitest-reporters'

  # For stopping test backtraces reaching beyound my own code
  #gem 'mini_backtrace'

  # Capybara lets us simulate users interacting with the interface
  gem 'minitest-rails-capybara'

  # For more readable test code using spec syntax
  gem 'minitest-spec-rails'

  # Open browser on page that is being tested whe test fails.
  gem 'launchy'

end

group :production do

  # used by Heroku to serve static assets
  gem 'rails_12factor'

  # Puma is a production server
  gem 'puma'
end

