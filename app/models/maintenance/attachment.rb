class Maintenance::Attachment < ApplicationRecord

  belongs_to :equipmentable, polymorphic: true
  mount_uploader :file, EquipmentAttachmentUploader

end
