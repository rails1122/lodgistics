Apipie.configure do |config|
  config.app_name                = "Lodgistics Mobile API"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/documentation"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.validate                = false
  config.show_all_examples       = true
  config.reload_controllers      = Rails.env.development?
  config.translate               = false
  # config.authenticate          = Proc.new do
  #   authenticate_or_request_with_http_basic do |username, password|
  #     username == ENV['DOC_USER_NAME'] && password == ENV['DOC_USER_PASSWORD']
  #   end
  # end
  config.app_info                = <<-EOS
    <b>Application Authentication</b>

    All Requests must be signed with an <tt>AUTHORIZATION</tt> header, unless
    marked [PUBLIC].

    This is a token provided during authentication and used to validate
    as well as identify users.

    E.g.,

      "AUTHORIZATION" => "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    Any incorrectly authorized requests will return  <tt>message:
    'Invalid Authentication Token.'</tt> with status <tt>401</tt>.

    E.g.,
      {
        "success": false,
        "payload": {
          "status": 401,
          "message": "Invalid Authentication Token."
        }
      }


    All Request must be signed with an <tt>PROPERTY-TOKEN</tt> header.
    This is a token provided during authentication(default_primary) or any property tokens.
    If you want to retrieve data for speicfic hotel, please specify that property token.

    Any incorrect property token request will return <tt>message: 'Invalid property token'</tt>
    with status <tt>400</tt>.

    If user doesn't have any access to that property specific with token, server rejects request
    with <tt>message: User is not belongs to this hotel</tt> with status <tt>400</tt>.
  EOS
end
