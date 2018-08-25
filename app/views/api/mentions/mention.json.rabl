object @mention

attribute :id => :mention_id
attributes :status, :user_id, :created_at, :updated_at, :mention_type, :property_id, :snoozed_at
node(:snoozed) { |i| i.snoozed? }
node(:mentioned_user_ids) { |i| i.mentionable.try(:mentioned_user_ids) }
node(:acknowledged_by_me) { |i| i.acknowledged_by?(current_user) }
node(:content) do |i|
  {
    content_id: i.mentionable.try(:id),
    parent_content_id: i.mentionable.try(:parent_id),
    content_data: i.mentionable_type == 'ChatMessage' ? i.mentionable.try(:message) : i.mentionable.try(:body),
    content_type: i.mentionable_type == 'ChatMessage' ? i.target_group.try(:chat_type) : 'feed',
    content_type_id: i.target_group.try(:id),
    content_type_name: i.target_group.try(:name),
    content_image: '',
    room_number: i.mentionable.try(:room_number),
    room_id: i.mentionable.try(:room).try(:id),
    created_by: {
      id: i.created_by.id,
      name: i.created_by.name,
      avatar: i.created_by.avatar.url,
      avatar_img_url: i.created_by.img_url,
      role: i.created_by.current_property_user_role.try(:role).try(:name),
    }
  }
end
