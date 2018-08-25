module Api::PasswordsDoc
  extend BaseDoc

  namespace 'api'
  resource :passwords

  doc_for :create do
    api :POST, '/passwords', '[PUBLIC] Send reset password instruction for given email'
    param :user, Hash, required: true do
      param :email,    String, required: true
    end
    description <<-EOS
      If successful, it returns an json with following data, with status <tt>200</tt>
      Response Object:
        reset_password_sent_at: time reset password instruction was sent at
        email: email address where reset password instruction was sent to
      If email is not found, it returns status <tt>400</tt>.
    EOS
    example <<-EOS
{
      "reset_password_sent_at": "2017-07-06T23:31:55.777-04:00",
      "email": 'user@email.com'
}
    EOS
  end

  doc_for :update do
    api :PUT, '/passwords', 'update password for current user'
    param :user, Hash, required: true do
      param :password,    String, required: true
      param :password_confirmation,    String, required: true
    end

    error 400, "Not Found"
    error 401, "Unauthorized (e.g. not authorized to access this item)"
    error 500, "Server Error"

    description <<-EOS
      If successful, it returns an empty json.
    EOS
  end
end
