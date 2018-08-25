object @user

attributes :id, :name, :email, :title, :username, :phone_number, :is_system_user

node(:avatar_img_url) do |u|
  u.img_url
end

child(:departments) do
  extends('api/users/department')
end

node(:role) do |u|
  u.current_property_role&.name
end

node(:role_id) do |u|
  u.current_property_role&.id
end
