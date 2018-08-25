class Acknowledgement < ActiveRecord::Base
  belongs_to :acknowledeable, polymorphic: true
  belongs_to :user
  belongs_to :target_user, class_name: 'User', foreign_key: :target_user_id

  scope :sent_by, -> (u) { where(user_id: u.id) if u.present? }
  scope :received_by, -> (u) { where(target_user_id: u.id) if u.present? }

  def check
    update(checked_at: DateTime.now)
  end

  def checked?
    self.checked_at != nil
  end
end
