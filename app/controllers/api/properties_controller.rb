class Api::PropertiesController < Api::BaseController
  include PropertiesDoc

  skip_before_action :authenticate_user_from_token, only: [ :create ]
  skip_before_action :set_property, only: [ :create ]
  skip_before_action :set_resource

  load_and_authorize_resource only: [ :index ]

  def index
    render json: @properties
  end

  def create
    # TODO : not the best way to validate parameters.
    # For some reasons, adding unique validation on property model breaks tests.
    @property = Property.new(property_params)
    if check_for_duplicate_address(@property)
      render json: { message: 'duplicate street address found' }, status: 422
      return
    end


    @property.generate_token
    @property.save!
    @property.setup_default_departments
    @property.setup_default_maintenance_categories(current_user)
    @property.setup_default_maintenance_public_areas(current_user)
    @property.setup_default_permissions

    new_user_created = false
    invitation_sent = false
    if params[:user].present?
      user_p = invite_user_params
      h = UserInvitationService.new.execute(user_p, @property, nil)
      new_user_created = h[:new_user_created]
      invitation_sent = h[:invitation_sent]
    end
    msg = get_response_msg(invitation_sent, new_user_created)
    render json: { new_user_created: new_user_created, invitation_sent: invitation_sent, message: msg }
  end

  private

  def get_response_msg(invitation_sent, new_user_created)
    msg = ""
    if invitation_sent
      msg = "Invitation Sent. Please check your email to accept invitation"
    elsif new_user_created
      msg = 'New User Created. Please check your email to activate'
    end
    msg
  end

  def invite_user_params
    params.require(:user).permit(:name, :email, :phone_number)
  end

  def property_params
    # corporate : name, username, useremail
    # property : name, username, useremail, timezone
    # properties: [ proprety, ... ]
    #params.require(:property).permit(:name, :contact_name, :street_address, :zip_code, :city, :email, :phone, :fax, :time_zone, :token)
    params.require(:property).permit(:name, :street_address, :city, :state, :zip_code, :time_zone)
  end

  def check_for_duplicate_address(property)
    return false if property.full_address.blank?
    addresses = Property.all.map { |i| i.full_address }
    l = addresses.map { |i| i.try(:downcase) }
    l.include?(property.full_address.try(:downcase))
  end
end
