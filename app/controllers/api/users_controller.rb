module Api
  class UsersController < BaseController
    include UsersDoc

    skip_before_action :set_resource, only: [ :show, :update, :create ]
    skip_before_action :authenticate_user_from_token, only: [:confirm, :request_confirm]

    load_and_authorize_resource only: [ :show, :update, :create ]

    def index
      target = current_user.corporate? ? current_user.corporate : Property.current
      @users = target.users.active.general.includes(:current_property_role, :departments)
      @users += [ User.lodgistics_bot_user ]
    end

    def update
      @user.update(update_user_params)
      set_user_role
      set_departments
    end

    def request_confirm
      @user = resource_class.find_by_confirmation_token! params[:confirmation_token]
      unless @user
        render_error({error: 'Cannot find user with confirmation token'})
      end
    end

    def confirm
      @user = User.find params[:id]
      title = params[:user].delete :title
      
      @user.current_property_user_role.title = title if title
      @user.assign_attributes(confirm_params)
  
      if @user.valid? && @user.password_match? && @user.save
        @user.confirm
      else
        render_error @user.errors
      end
    end

    def roles_and_departments
      @roles = Role.all
      @departments = Department.unscoped.for_property_id(Property.current_id)
      render json: { roles: @roles.as_json,
                     departments: @departments.as_json(only: [:id, :name, :property_id]) }
    end

    def create
      render json: {}
    end

    def invite
      user_p = invite_user_params
      corporate = nil
      property = Property.find_by(token: params[:user][:property_token])

      if user_p[:email].blank? && user_p[:phone_number].blank?
        render json: {error: 'email or phone number must be set'}, status: 422
        return
      end

      if property.nil?
        render json: {error: 'property not found with given property_token'}, status: 422
        return
      end

      result = UserInvitationService.new.execute(user_p, property, corporate)
      render json: result[:user]
    end

    def multi_invite
      corporate = nil
      results = []
      p = multi_invite_params
      p[:users].each do |user_p|
        property = Property.find_by(token: user_p[:property_token])

        if user_p[:email].blank? && user_p[:phone_number].blank?
          render json: {error: 'email or phone number must be set'}, status: 422
          return
        end

        if property.nil?
          render json: {error: 'property not found with given property_token'}, status: 422
          return
        end
        h = UserInvitationService.new.execute(user_p, property, corporate)
        results << UserSerializer.new(h[:user]).as_json
      end
      render json: { users: results }
    end

    private

    def property_params
      params.require(:property).permit(:name, :street_address, :city, :state, :zip_code, :time_zone)
    end

    def invite_user_params
      params.require(:user).permit(:name, :email, :phone_number, :role_id, :department_id)
    end

    def multi_invite_params
      params.permit(users: [ :name, :email, :phone_number, :role_id, :department_id, :property_token ])
    end

    def user_params
      params.require(:user).permit(:name)
    end

    def update_user_params
      params[:user][:remote_avatar_url] = params[:user][:avatar_img_url]
      params.require(:user).permit(:name, :title, :phone_number, :remote_avatar_url)
    end

    def confirm_params
      params[:user][:remote_avatar_url] = params[:user][:avatar_img_url]
      params.require(:user).permit(:name, :title, :phone_number, :remote_avatar_url, :password, :password_confirmation)
    end

    def set_user_role
      role = Role.find_by(id: params[:user][:role_id])
      if role.present?
        @user.current_property_role = role
        @user.save
      end
    end

    def set_departments
      departments = Department.where(id: params[:user][:department_ids])
      if departments.present?
        @user.departments = departments
        @user.save
      end
    end
  end
end
