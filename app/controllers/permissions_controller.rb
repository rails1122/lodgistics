class PermissionsController < ApplicationController
  before_action :authorize_permission
  respond_to :html, :json

  def index
    @role_id = params[:role_id].to_i
    @department_id = params[:department_id].to_i
    @filter = params[:filter]
    @roles = if @filter == 'active'
               Role.for_current_property
             elsif @filter == 'all'
               Role.all
             else
               []
             end
    @role_id = @roles.first.id if @roles.any? && !@roles.pluck(:id).include?(@role_id)
    @departments = if @filter == 'active'
                     Department.with_roles(@role_id).order(:name)
                   elsif @filter == 'all'
                     Department.order(:name)
                   else
                     []
                   end
    @department_id = @departments.first.id if @departments.any? && !@departments.map(&:id).include?(@department_id)
    @users = User.by_roles_and_departments(@role_id, @department_id).general
    @roots = PermissionAttribute.roots
    @permission_values = Permission.permitted(@role_id, @department_id)
    render layout: false
  end

  def update_all
    role_id = params[:permissions].delete :role
    department_id = params[:permissions].delete :department
    filter = params[:permissions].delete :filter
    permissions = permissions_params

    @permissions = Permission.permitted(role_id, department_id)
    permitted_ids = []
    permissions.each do |subject, actions|
      actions.each do |action, options|
        option = []
        permission_attribute_id = options
        if options.kind_of? Hash
          option = options.keys.map { |oo| oo == 'department' ? {option: oo.to_sym, departments: params[:departments]} : oo.to_sym }
          next if option.count == 0
          permission_attribute_id = options[options.keys.first]
        end
        permitted = Permission.find_or_initialize_by(role_id: role_id, department_id: department_id, permission_attribute_id: permission_attribute_id)
        permitted.options = option
        permitted.save
        permitted_ids.push permitted.id
      end
    end
    @permissions.where(id: @permissions.pluck(:id) - permitted_ids).destroy_all
    redirect_to property_settings_path(role_id: role_id, department_id: department_id, filter: filter), notice: 'Permissions have been updated successfully.'
  end

  private

  def permissions_params
    params.require(:permissions).permit(
      access: [[
        :settings, :connect_corporate, :permission_setting, :procurement,
        :maintenance, :work_order, :pm_setup, :pm, :inspection
      ]],
      maintenance_work_order: [
        :create, :edit_closed, :assignable, :destroy,
        index: [[:all, :own, :assigned_to]],
        edit: [[:priority, :status, :due_to_date, :assigned_to_id]]
      ],
      maintenance_checklist_item_maintenance: [[:single_click_pm]],
      report: [[:index]], user: [[:index]]
    ).to_h
  end

  def authorize_permission
    authorize :access, :permission_setting?
  end

end
