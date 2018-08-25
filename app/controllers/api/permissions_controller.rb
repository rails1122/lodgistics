class Api::PermissionsController < Api::BaseController
  def index
    @user_permissions = current_user.permissions
    permission_attributes = PermissionAttribute.all
    permissions_data = Hash.new

    permission_attributes.group_by(&:parent_id).each do |parent_id, items|
      parent_pa = items.first.parent
      parent_permission = parent_pa ? permission_value(parent_pa) : true
      permissions_data[parent_id || "root"] = Array.new
      items.each do |item|
        item_data = item.as_json.merge({ permitted: parent_permission && permission_value(item) })
        if item["options"].present?
          item_data["options"] = item[:options].map{|o| o.merge({ permitted: parent_permission && permission_value(item, o) })}
        end

        permissions_data[parent_id || "root"] << item_data
      end
    end

    render json: permissions_data.as_json, root: false
  end

  private

  def permission_value(attribute, option = nil)
    permitted = @user_permissions.where(permission_attribute_id: attribute.id).first
    permitted.present? && (option.present? ? (permitted.options || []).include_in_hash?(option[:option]) : true)
  end
end
