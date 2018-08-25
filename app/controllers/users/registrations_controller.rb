class Users::RegistrationsController < Devise::RegistrationsController

  def destroy
    render body: nil, status: :forbidden
  end

  protected
    def after_sign_up_path_for(resource)
      signed_in_root_path(resource)
    end

    def after_update_path_for(resource)
      signed_in_root_path(resource)
    end
end
