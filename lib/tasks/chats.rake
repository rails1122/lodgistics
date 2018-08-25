namespace :chats do
  desc "Generate test chat data"
  task dummy: :environment do
    Property.current_id = 33

    animesh = User.find_by email: 'animesh.jain@galaxyweblinks.in'
    akansha = User.find_by email: 'akansha.agarwal@galaxyweblinks.in'
    gaurav = User.find_by email: 'gaurav.malviya@galaxyweblinks.in'
    nikhil = User.find_by email: 'nikhilnatu@gmail.com'
    hugo = User.find_by email: 'bhugo313@gmail.com'

    galaxy = Chat.create(name: "Galaxy Team", created_by_id: animesh.id)
    galaxy.users << animesh << akansha << gaurav

    g_msg = galaxy.messages.create(sender_id: animesh.id, message: 'Hey Guys')
    g_msg.read_by!(akansha)

    g_msg = galaxy.messages.create(sender_id: akansha.id, message: 'Hi Animesh')
    g_msg.read_by!(animesh)

    g_msg = galaxy.messages.create(sender_id: gaurav.id, message: 'Hi Akansha')
    g_msg.read_by!(animesh)

    mobile = Chat.create(name: "Mobile Team", created_by_id: nikhil.id)
    mobile.users << animesh << akansha << gaurav << nikhil << hugo

    g_msg = mobile.messages.create(sender_id: nikhil.id, message: 'Hey Guys, welcome to mobile team!')
    g_msg.read_by!(akansha)
    g_msg.read_by!(hugo)

    g_msg = mobile.messages.create(sender_id: hugo.id, message: 'Hi Galaxy Team')
    g_msg.read_by!(animesh)
    g_msg.read_by!(nikhil)

    g_msg = mobile.messages.create(sender_id: gaurav.id, message: 'Hi Nikhil')
    g_msg.read_by!(animesh)
  end

  desc "Update chat message reads count"
  task update_read_count: :environment do
    Property.all.each do |p|
      p.run do
        ChatMessage.pluck(:id).each { |id| ChatMessage.reset_counters(id, :reads) }
      end
    end
  end
end
