object @user
extends('api/users/user_with_avatar_img_url')
node(:push_notification_enabled) { |u| !!u.push_notification_setting&.enabled? }