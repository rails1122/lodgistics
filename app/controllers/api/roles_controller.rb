class Api::RolesController < Api::BaseController
  include RolesDoc

  skip_before_action :set_resource

  def index
    @roles = Role.all
    render json: @roles.as_json
  end

  private

end
