Airbrake.configure do |config|
	config.environment = Rails.env
	config.project_id = ENV["AIRBRAKE_PROJECT_ID"] || '1234'
	config.project_key =  ENV["AIRBRAKE_API_KEY"] || 'dummy'
  config.ignore_environments = %w(development test)
end

# Let's ignore airbrake if airbrake env vars are not there
unless ENV['AIRBRAKE_API_KEY'] && ENV['AIRBRAKE_PROJECT_ID']
  Airbrake.add_filter(&:ignore!)
end
