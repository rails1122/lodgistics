object @group

attributes :id, :is_already_created, :is_private, :created_at, :updated_at, :image_url
attribute created_by_id: :owner_id

node(:name) { |i| i.chat_title(current_user) }

child chat_users: :users do |group_user|
  glue :user do
    attributes :id, :name, :title
    node(:avatar) do |u|
      {
        url: u.avatar.url,
        medium: u.avatar.url(:medium),
        thumb: u.avatar.url(:thumb)
      }
    end
  end
  attribute created_at: :joined_at
end

node(:last_message) { |g| partial('api/chats/message', object: g.last_message) }
node(:unread) { |g| g.chat_messages.unread(current_user.id).count }

