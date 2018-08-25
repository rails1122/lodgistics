object @user

attributes :id, :name, :email, :title, :is_system_user

node(:avatar) do |u|
  {
    url: u.avatar.url,
    medium: u.avatar.url(:medium),
    thumb: u.avatar.url(:thumb)
  }
end

node(:avatar_img_url) { |u| u.img_url }
