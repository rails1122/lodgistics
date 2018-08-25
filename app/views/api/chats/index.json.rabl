object false

child @groups => :groups do
  extends('api/chats/group')
end

child @privates => :privates do
  extends('api/chats/group')
end
