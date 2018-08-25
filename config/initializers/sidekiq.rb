sidekiq_config = { url: ENV['JOB_WORKER_URL'] || 'redis://localhost:6379', :namespace => 'lodgistics' }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

Sidekiq::Extensions.enable_delay!
