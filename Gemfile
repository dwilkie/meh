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
gem 'delayed_job'
gem 'action_sms'
gem 'paypal-ipn', :require => 'paypal', :path => '/home/dave/work/plugins/paypal'
gem "haml-rails"
gem "simple_form"

# gem 'bj'
# gem 'nokogiri', '1.4.1'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :development, :test do
  gem 'ruby-debug19'
  gem 'rspec-rails', '>= 2.4'
end

## Bundle gems for certain environments:
group :test do
  gem "test-unit"
  gem 'cucumber-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'pickle', '>= 0.4.4'
  gem 'spork', '>=0.9.0.rc2'
  gem 'fakeweb'
  gem 'launchy'
end

