require 'test_helper'

describe Api::PermissionsController do
  let(:departments) { create_list(:department, 2, property: @property) }
  let(:permission) do
    create(:permission, role: Role.gm, department: Department.first, permission_attribute: attribute('Team'))
  end

  describe "#index" do
    before do
      create_user_for_property(Role.gm)
      departments
      permission

      @request.headers['HTTP_PROPERTY_TOKEN'] = @property.token
      @request.headers['HTTP_AUTHORIZATION'] = @api_key.access_token
    end

    it "should respond with user permissions grouped by parent_id" do
      get :index
      root_permissions = JSON.parse(response.body)["root"]

      assert(root_permissions.count == PermissionAttribute.roots.count)
      assert(root_permissions.select{|v| v["id"] == permission.permission_attribute.id }[0]["permitted"] == true)
    end
  end
end
