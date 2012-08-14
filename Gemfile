source 'https://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'gds-api-adapters', '0.2.2'

if ENV['BUNDLE_DEV']
  gem 'gds-sso', path: '../gds-sso'
else
  gem 'gds-sso', '1.2.1'
end

gem 'gds-warmup-controller', '0.0.2'

gem 'rails', '3.2.7'
gem 'aws-ses', '0.4.4', require: 'aws/ses'

gem 'erubis', '2.7.0'
gem 'plek', '0.1.24'
gem 'gelf', '1.1.3'
gem 'graylog2_exceptions', '1.3.0'
gem 'rest-client', '1.6.7'

gem 'null_logger', '0.0.1'
gem 'daemonette', git: 'git@github.com:alphagov/daemonette.git'

gem "colorize", "0.5.8"

gem 'inherited_resources', '1.3.1'
gem 'formtastic', git: 'git://github.com/justinfrench/formtastic.git', branch: '2.1-stable'
gem 'formtastic-bootstrap', git: 'git://github.com/cgunther/formtastic-bootstrap.git', branch: 'bootstrap-2'
gem 'has_scope', '0.5.1'
gem 'kaminari', '0.13.0'
gem 'lograge', '0.0.6'

gem 'sanitize', '2.0.3'
gem 'htmlentities', '4.3.1'

if ENV['CONTENT_MODELS_DEV']
  gem "govuk_content_models", :path => '../govuk_content_models'
else
  gem "govuk_content_models", "0.5.1"
end

gem 'mongo', '1.6.2'  # Locking this down to avoid a replica set bug

if ENV['CDN_DEV']
  gem 'cdn_helpers', path: '../cdn_helpers'
else
  gem 'cdn_helpers', '0.9'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '0.8.18'
end

gem 'exception_notification', '2.6.1', require: 'exception_notifier'

gem 'lockfile', '2.1.0'
gem 'whenever', '0.7.3'
gem 'newrelic_rpm', '3.3.4.1'

group :assets do
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end

group :test do
  gem 'test-unit'
  gem 'shoulda'
  gem 'database_cleaner'

  gem 'cucumber-rails', require: false

  gem 'capybara', '~> 1.0.0'
  gem "capybara-webkit"
  gem 'launchy'

  gem 'webmock'
  gem 'mocha', require: false
  gem 'factory_girl_rails'
  gem 'faker'

  gem "timecop"

  gem 'simplecov', '~> 0.6.4', :require => false
  gem 'simplecov-rcov', '~> 0.2.3', :require => false
  gem 'ci_reporter'
end
