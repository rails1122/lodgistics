class Api::DepartmentsController < Api::BaseController
  include DepartmentsDoc

  skip_before_action :set_resource

  def index
    @departments = Department.unscoped.for_property_id(Property.current_id)
    render json: @departments.as_json(only: [:id, :name, :property_id])
  end

  private

end
