object @user

attributes :id, :name, :email, :title, :username, :is_system_user

node(:avatar) do |u|
  u.avatar_obj
end

node(:avatar_img_url) do |u|
  u.img_url
end

child(:departments) do
  extends('api/users/department')
end

node(:role) do |u|
  u.current_property_role.try(:name)
end

node(:role_id) do |u|
  u.current_property_role.try(:id)
end
