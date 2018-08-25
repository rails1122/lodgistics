object @user
attributes :email, :name
child(:devices) { attributes :token, :platform, :enabled }
node(:push_notification_enabled) { |u| !!u.push_notification_setting&.enabled }