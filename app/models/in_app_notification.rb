class InAppNotification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true

  belongs_to :property
  belongs_to :recipient_user, class_name: 'User', foreign_key: :recipient_user_id

  enum notification_type: {
    not_specified: 0,
    new_feed: 100,
    unread_message: 200,
    work_order_completed: 300,
    permission_updated: 400,
    new_work_order: 500,
  }

  def read
    !self.read_at.nil?
  end


end
