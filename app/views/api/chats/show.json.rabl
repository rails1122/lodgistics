object @chat
attributes :name, :property_id, :updated_at, :created_at, :last_message_at, :image

child(:users) do
  extends('api/users/user')
end

#extends('api/chats/group')
