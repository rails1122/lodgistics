class S3WriteService
  def write(s3_key, data_blob)
    s3 = Aws::S3::Resource.new(region: Settings.lodgistics_s3_region,
                               access_key_id: Settings.lodigstics_aws_access_key,
                               secret_access_key: Settings.lodigstics_aws_secret_access_key)
    obj = s3.bucket(Settings.lodigstics_s3_bucket_name).object(s3_key)
    obj.put(body: data_blob)
  end
end
