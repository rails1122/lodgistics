module Api
  class PasswordsController < BaseController
    include PasswordsDoc

    skip_before_action :authenticate_user_from_token, only: [ :create ]
    skip_before_action :set_property, only: [ :create ]
    skip_before_action :set_resource

    def create
      set_user
      if @user.blank?
        render json: { error: 'email not found' }, status: 400
        return
      end

      @user.send_reset_password_instructions
      @user.reload
      json = { email: @user.email, reset_password_sent_at: @user.reset_password_sent_at}
      render json: json, status: 200
    end

    def update
      if @current_user.update(password_params)
        render json: {}, status: 200
      else
        error_messages = @current_user.errors.full_messages
        render json: { messages: error_messages, errors: error_messages }, status: 400
      end
    end

    private

    def set_user
      @user = User.where("lower(email) = ?", password_params[:email].to_s.downcase).first
    end

    def password_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end
