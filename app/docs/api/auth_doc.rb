module Api::AuthDoc
  extend BaseDoc

  namespace 'api'
  resource :auth

  doc_for :s3_sign do
    api :GET, '/s3_sign', 'Generates and returns signed url used for s3 upload'
    param :objectName,  String, "<tt>filename (e.g. SampleVideo_1280x720_1mb.mp4)</tt>", required: true
    param :contentType, String, "<tt>content type (e.g. video/mp4)</tt>", required: true
    param :uploadType,  String, "<tt>video | photo</tt>", required: true
    description <<-EOS
      if successful, returns following JSON:
        signedUrl: signed url (e.g. "https://s3.amazonaws.com/lodgistics-development/videos/upload/e1858754-e22a-4f46-93de-52e6fc19f83c_SampleVideo_1280x720_1mb.mp4?X-Amz-Expires=900&X-Amz-Date=20170628T153316Z&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAJAYHBLM26AYQLMQQ/20170628/us-east-1/s3/aws4_request&X-Amz-SignedHeaders=content-type%3Bhost%3Bx-amz-acl&X-Amz-Signature=ab5b568a500c842c3bdba12acd0592caca35fe3c670c12e9f080e4008e02e0f7”)
        filename: filename (s3 key) in bucket (e.g. "videos/upload/e1858754-e22a-4f46-93de-52e6fc19f83c_SampleVideo_1280x720_1mb.mp4")
    EOS
  end

  doc_for :create do
    api :POST, '/auth', '[PUBLIC] Authorizes a user account.'
    param :user, Hash, required: true do
      param :email,    String, required: true
      param :password, String, required: true
      param :device_platform, ['ios', 'android'], 'device platform'
      param :device_token, String, 'device token - this should be the one generated from Ionic'
    end
    description <<-EOS
      If successful, it returns an <tt>access_token</tt> and <tt>user</tt> object
      subsequent requests and user basic profile, with status <tt>200</tt>.
      Response Object:
        access_token: Random token for all subsequent request
        user: Object for user basic profile
          name: User name
          role: Should be nil
          avatar: User avatar url
          email: User email
          username: Username
          default_property: Default property token for user
          properties: Object list for all properties user have access: name and token
            id: property id
            name: property name
            token: property token
            created_at: creation time
      If unsuccessful, it returns status <tt>401</tt>.
    EOS
  end
end
