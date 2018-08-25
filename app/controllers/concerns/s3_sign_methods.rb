module S3SignMethods
  extend ActiveSupport::Concern

  included do
    def s3_sign
      object_name = params[:objectName]
      if object_name.blank?
        render json: {error: 'objectName parameter is blank.'}, status: 422
        return
      end

      upload_type = params[:uploadType]
      if upload_type.blank?
        render json: {error: 'uploadType parameter is blank.'}, status: 422
        return
      end

      unless (upload_type == 'image' || upload_type == 'photo' || upload_type == 'video')
        render json: {error: 'uploadType must be one of image, photo, or video'}, status: 422
        return
      end

      s3_key = "#{upload_type}s/upload/#{SecureRandom.uuid}_#{object_name}"
      s3FileUrl = "https://#{Settings.lodigstics_s3_bucket_name}.s3.#{Settings.lodgistics_s3_region}.amazonaws.com/" + s3_key
      render json: { signedUrl: get_signed_url(s3_key), filename: s3_key, s3FileUrl: s3FileUrl }
    end

    private

    def get_signed_url(s3_key)
      s3 = Aws::S3::Resource.new(region: Settings.lodgistics_s3_region,
                                 access_key_id: Settings.lodigstics_aws_access_key,
                                 secret_access_key: Settings.lodigstics_aws_secret_access_key)
      obj = s3.bucket(Settings.lodigstics_s3_bucket_name).object(s3_key)
      put_url = obj.presigned_url(:put, acl: 'public-read', expires_in: 3600 * 24)
      put_url
    end
  end
end

