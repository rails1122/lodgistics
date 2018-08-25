class UserInvitationService
  def execute(param, property, corporate)
    return nil if property.blank?

    property.run do
      current_property_user_role_attributes = {
        title: 'General Manager',
        order_approval_limit: 0,
        role_id: Role.gm.id,
        property_id: property.id
      }
      department_ids = [Department.find_or_create_by(name: 'All').id]

      if param[:role_id].present?
        role = Role.find(param[:role_id])
        current_property_user_role_attributes = {
          title: role.try(:title),
          order_approval_limit: 0,
          role_id: param[:role_id],
          property_id: property.id
        }
      end

      if param[:department_id].present?
        department = Department.unscoped.find(param[:department_id])
        department_ids = [ department.id ]
      end

      user_params = {
        name: param[:name].blank? ? "First & Last Name" : param[:name],
        email: param[:email],
        phone_number: param[:phone_number],
        current_property_user_role_attributes: current_property_user_role_attributes,
        department_ids: department_ids
      }
      user = user_params[:phone_number].present? ? User.find_by(phone_number: user_params[:phone_number]) : User.find_by(email: user_params[:email])

      new_user_created = false
      invitation_sent = false
      if user
        send_invitation(user, corporate, property, user_params)
        invitation_sent = true
      else
        user = create_user(user_params)
        new_user_created = true
        # TODO : send invitation here, too
        if user_params[:phone_number].present?
          send_sms(user_params[:phone_number], property, user)
        end
        Mailer.send_invitation(user.id, property.id).deliver if user.email.present?
      end

      return { user: user, new_user_created: new_user_created, invitation_sent: invitation_sent }
    end
  end

  private

  def send_invitation(user, corporate, property, user_params)
    invitation = JoinInvitation.create(
        sender: corporate ? corporate.users.first : nil,
        invitee: user,
        targetable: property,
        params: user_params
    )
    Mailer.join_invitation(invitation.id)
  end

  def create_user(user_params)
    user = User.new
    user.skip_confirmation_notification!
    user.update_attributes user_params
    user
  end

  def send_sms(phone_number, property, user)
    client = TwilioClient.new
    body = "lodgistics://app/create/#{property.token}/#{user.confirmation_token}"
    client.send_sms(phone_number, body)
  rescue => e
    Airbrake.notify(e)
    true
  end
end
