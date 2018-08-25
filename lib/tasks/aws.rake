namespace :aws do
  desc 'Upload local images to AWS'
  task upload: :environment do
    User.all.each do |u|
      next unless u.avatar_identifier

      path = "#{Rails.root}/public/uploads/user/avatar/#{u.id}/#{u.avatar_identifier}"
      next unless File.exist?(path)

      u.avatar = File.open path
      u.save
    end

    Message.all.each do |m|
      next unless m.attachment_identifier

      path = "#{Rails.root}/public/uploads/message/attachment/#{m.id}/#{m.attachment_identifier}"
      next unless File.exist?(path)

      m.attachment = File.open path
      m.save
    end

    Maintenance::Attachment.all.each do |m|
      next unless m.file_identifier

      path = "#{Rails.root}/public/uploads/maintenance/attachment/file/#{m.id}/#{m.file_identifier}"
      next unless File.exist?(path)

      m.file = File.open path
      m.save
    end
  end
end