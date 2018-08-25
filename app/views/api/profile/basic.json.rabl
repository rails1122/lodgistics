object @user

extends('api/profile/base')
attributes :email, :username, :name
node(:default_property) { |user| user.primary_property.try(:token) }
child :all_properties_with_primary_property_in_front do |p|
  attribute :id, :name, :token, :created_at
end
