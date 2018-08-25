module ApiMacros
  def auth_with_user(user)
    FactoryGirl.create(:api_key, user: user)
  end

  def api_response
    JSON.parse(response.body)
  end

  def create_user_for_property(role = Role.gm)
    @property = FactoryGirl.create(:property)
    @property.switch!
    @user = FactoryGirl.create(:user, current_property_role: role)
    @api_key = auth_with_user(@user)
  end
end
