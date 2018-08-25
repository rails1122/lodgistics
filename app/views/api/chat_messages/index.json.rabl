object false

@messages.each do |id, list|
  node(id.to_s) do
    list.map { |msg| partial('api/chat_messages/message', object: msg) }
  end
end
