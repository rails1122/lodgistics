object @user
attributes :id, :name
node(:role) { |user| user.try(:current_property_role).try(:name) }
node(:title) { |user| user.try(:title) }
node(:avatar) { |user| user.avatar.url }
node(:avatar_img_url) { |u| u.img_url }
