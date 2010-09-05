# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  #config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  
  
  
  #TODO: locate correct SMTP & authentication information
  # authenticated smtp server for NCSU is
  #    smtp.ncsu.edu
  # a valid login/password is required for this server.
  # if part of resnet, we can use 
  #   smtp-resnet.ncsu.edu 
  # without authentication
  # Comment out the test line once 
  
  config.active_record.timestamped_migrations = false
  
  config.action_controller.session = {
       :key => 'pg_session',
       :secret => '3d70fee70cddd63552e8dd6ae6c788060af8fb015da5fef83d368abf37aa10c112d842d7c038420845109147779552cdd687ec4e2034cec3046dc439d8a468e'
  }
  config.action_controller.session_store = :p_store
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "smtp.ncsu.edu",
    :port => 25,
    :domain => "localhost"
  }
end

 #Running background process to send e-mails constantly
#ActionBase::SpawnHelper.background()
#ActionController::SpawnHelper.background()
#
#include Spawn
#spawn do    
#  while 1
#    ActionController::Mailer.deliver_message(
#        {:recipients => "lramach@ncsu.edu",
#         :subject => "Testing the E-mail System!",
#         :body => "Helllooooooo!"
#        }
#    )
#    sleep 60
#  end
#end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
#ActionController::AbstractRequest.relative_url_root = "/blog"
NO = 1
LATE = 2
OK = 3