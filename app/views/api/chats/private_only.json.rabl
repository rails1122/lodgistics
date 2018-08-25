object @chats

node(:target_user) { |g| u = g.target_user(current_user); partial('api/chats/simplified_user', object: u) }
node(:chat)  { |g| partial('api/chats/group', object: g) }
