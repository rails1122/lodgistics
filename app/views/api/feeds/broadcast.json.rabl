object @feed
attributes :id, :title, :body, :created_at, :updated_at, :broadcast_start, :broadcast_end
node(:body) { |i| i.body_without_mention_tags }
node(:created_by) { |feed| partial('api/profile/base', object: feed.created_by) }
