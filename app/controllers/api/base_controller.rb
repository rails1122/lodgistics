module Api
  class BaseController < ActionController::Base
    include Pundit
    include ApiErrorResponses

    protect_from_forgery with: :null_session
    respond_to :json

    skip_before_action :verify_authenticity_token
    before_action :authenticate_user_from_token
    before_action :set_property
    before_action :set_resource, only: [:destroy, :show, :update]

    def current_user
      access_token = request.headers['HTTP_AUTHORIZATION']
      @api_key ||= ApiKey.find_by(access_token: access_token)
      @current_user ||= @api_key.try :user

      unless @current_user
        devise_session_id = session['warden.user.user.key'].try(:[], 0).try(:[], 0)
        if devise_session_id
          @from_session = true
          @current_user = User.find_by id: devise_session_id
        end  
      end
      @current_user
    end

    def authenticate_user_from_token
      render_unauthorized({message: 'Invalid Authentication Request'}) unless current_user
    end

    def set_property
      if @from_session
        if current_user.corporate?
          if session[:property_id]
            return user_properties.where(id: session[:property_id]).first
          else
            return nil
          end
        end

        property = user_properties.where(id: session[:property_id]).first
        property ||= user_properties.first
      else
        property_token = request.headers['HTTP_PROPERTY_TOKEN']
        property = Property.find_by(token: property_token)
      end

      render_error({property: 'Invalid hotel token'}) and return if property.nil?
      Property.current_id = property.try(:id)
      if current_user && current_user.current_property_role.nil?
        render_error({user: 'User does not belong to this hotel'}) and return
      end
    end

    def user_properties
      @user_properties ||= current_user.all_properties
    end

    rescue_from ActionController::ParameterMissing do |exception|
      error = {}
      error[exception.param] = ['Parameter is required']
      render_error(error)
    end

    rescue_from Pundit::NotAuthorizedError do |e|
      flash[:alert] = 'You are not authorized to access page.'
      respond_to do |format|
        format.any(:all, :json) { render json: {error: 'You cannot perform this action'}, status: :forbidden }
        format.html { redirect_to request.env["HTTP_REFERER"] ? :back : '/' }
      end
    end

    protected

    def parse_time(time_str, default_value = Time.current)
      time_str.present? ? Time.zone.parse(time_str) : default_value
    end

    private

    def get_resource
      instance_variable_get("@#{resource_name}")
    end

    def query_params
      {}
    end

    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    def resource_name
      @resource_name ||= self.controller_name.singularize
    end

    def resource_params
      self.send("#{resource_name}_params")
    end

    def set_resource(resource = nil)
      resource ||= resource_class.find_by(id: params[:id].to_i)
      render_no_content if resource.blank?
      instance_variable_set("@#{resource_name}", resource)
    end
  end
end
