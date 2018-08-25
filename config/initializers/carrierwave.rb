unless Rails.env.test?
  CarrierWave.configure do |config|
    config.fog_provider     = 'fog/aws'  
    config.fog_credentials  = {
      :provider => 'AWS',
      :aws_access_key_id => Settings.lodigstics_aws_access_key,
      :aws_secret_access_key => Settings.lodigstics_aws_secret_access_key,
      :region => Settings.lodgistics_s3_region
    }
    config.fog_directory  = Settings.lodigstics_s3_bucket_name
    config.fog_public     = false
    config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  end
end