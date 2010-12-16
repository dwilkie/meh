source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
#gem 'rails', :git => 'git://github.com/rails/rails.git'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'devise', :git => "git://github.com/plataformatec/devise.git"
gem 'devise_paypal', :path => '/home/dave/work/plugins/devise_paypal'
gem 'conversational'
gem 'money'
gem 'httparty'
gem 'delayed_job', ">=2.1.2"
gem 'action_sms'
gem 'paypal-ipn', :require => 'paypal', :path => '/home/dave/work/plugins/paypal'
gem "haml-rails"
gem "simple_form"

# gem 'bj'
# gem 'nokogiri', '1.4.1'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

group :development do
  gem 'ruby-debug19'
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

## Bundle gems for certain environments:
group :test do
  gem "test-unit"
  gem 'rspec-rails', ">=2.2.1"
  gem 'factory_girl_rails'
  gem 'capybara', ">=0.4.0"
  gem 'database_cleaner'
  gem 'pickle'
  gem 'cucumber-rails'
  gem 'spork', ">=0.9.0.rc2"
  gem 'fakeweb'
  gem 'ruby-debug19'
  gem 'launchy'
end

