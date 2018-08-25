module Api
  class ProfileController < BaseController
    include ProfileDoc

    def update
      if get_resource.update(resource_params)
        render :update
      else
        render_unprocessable
      end
    end

    private

    def resource_name
      @resource_name = 'user'
    end

    def user_params
      if params[:user]
        params[:user][:devices_attributes] = (params[:user].slice(:token, :platform, :enabled) || {})
        params[:user][:devices_attributes][:id] = nil
      end
      params.require(:user).permit(:name, devices_attributes: [:id, :token, :platform, :enabled])
    end

    def set_resource
      @user = current_user
    end

    def render_unprocessable
      @api_errors = get_resource.errors.to_hash
      error_messages = get_resource.errors.full_messages
      render json: {errors: @api_errors, error_messages: error_messages}, status: 422
    end
  end
end
