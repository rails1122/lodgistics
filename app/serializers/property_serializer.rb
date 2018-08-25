class PropertySerializer < ActiveModel::Serializer
  attributes :id, :name, :street_address, :zip_code, :state, :city, :time_zone, :token
end
