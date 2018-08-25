object @feed

extends('api/feeds/feed')

child replies: :replies do
  extends('api/feeds/feed')
end
