class LoginController < ApplicationController
  def create
    @user = auth_with_token
    if @user
      sign_in @user
      redirect_to after_sign_in_path_for(@user)
    else
      redirect_to authenticated_root_path
    end
  end

  private

  def auth_with_token
    access_token = params[:auth_token]
    api_key = ApiKey.find_by(access_token: access_token)
    User.find(api_key.user_id) if api_key
  end
end