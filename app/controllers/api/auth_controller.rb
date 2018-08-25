module Api
  class AuthController < BaseController
    include AuthDoc
    include S3SignMethods

    skip_before_action :authenticate_user_from_token, only: [ :create, :s3_sign ]
    skip_before_action :set_property, only: [ :create, :s3_sign ]

    def create
      unless authenticate_user?
        render_unauthorized
        return
      end

      unless user.confirmed?
        render_unauthorized({message: 'User is not confirmed yet.'})
        return
      end

      find_or_create_api_key
      create_device
      render status: 201
    end

    private

    def user
      login_str = auth_params[:email]
      @user ||= User.where("lower(email) = ? OR lower(username) = ?", login_str.downcase, login_str.downcase).first
    end

    def authenticate_user?
      user && user.valid_password?(auth_params[:password])
    end

    def find_or_create_api_key
      @api_key = ApiKey.where(user: user).first_or_create
      Property.current_id = user.primary_property
    end

    def resource_class
      'api_key'.classify.constantize
    end

    def auth_params
      params.require(:user).permit(:email, :password, :device_token, :device_platform)
    end

    def create_device
      h = auth_params
      return if h[:device_token].blank? || h[:device_platform].blank?
      # find if someone else is using this device. if so, remove it.
      other_devices = Device.where(token: h[:device_token]).where.not(user_id: user.id)
      other_devices.destroy_all if other_devices.present?

      user.create_or_update_device(h)
    end
  end
end
