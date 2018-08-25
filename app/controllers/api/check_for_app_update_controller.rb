class Api::CheckForAppUpdateController < Api::BaseController
  include CheckForAppUpdateDoc
  
  skip_before_action :authenticate_user_from_token
  skip_before_action :set_property

  def index
    @mobile_version = MobileVersion.check_for_update(params[:platform], params[:version])
  end

end
