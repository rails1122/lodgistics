object @user
attributes :email, :name
child(:devices) { attributes :token, :platform, :enabled }