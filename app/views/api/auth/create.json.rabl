object @api_key

attribute :access_token
child(:user) do
  extends('api/profile/basic', user: @user)
end