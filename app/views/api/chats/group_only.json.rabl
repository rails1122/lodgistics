object @chats

node(:chat)  { |g| partial('api/chats/group', object: g) }

