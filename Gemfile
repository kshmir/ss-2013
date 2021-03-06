source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'rsruby'
gem 'resque'
gem 'resque-retry'
gem 'haml'
gem 'redis-objects'
gem 'bootstrap_forms'
gem 'foreman'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
	gem 'sass-rails',   '~> 3.2.3'
	gem 'coffee-rails', '~> 3.2.1'

	gem "therubyracer"
	gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
	gem "twitter-bootstrap-rails"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'guard'                   # Guard event handler.
  # Dependency to prevent polling. Setup for multiple OS environments.
  # Optionally remove the lines not specific to your OS.
  # https://github.com/guard/guard#efficient-filesystem-handling
  gem 'rb-inotify', :require => false # Linux
  gem 'rb-fsevent', :require => false # Mac OSX
  gem 'rb-fchange', :require => false # Windows

  gem 'guard-livereload'

  gem 'uglifier', '>= 1.0.3'

end

group :development do
	gem 'pry'
	gem 'pry-rails'
	gem 'pry-debugger'
	gem 'pry-stack_explorer'

  gem 'yaml_db'                      # Provides rake db:data:dump and db:data:load for backups
  gem 'awesome_print'                # Better console printing

  gem 'better_errors'
end
group :development, :test do
  gem 'rspec-rails'
	gem 'rspec-mocks'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
