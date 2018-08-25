module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # token based (for mobile)
      if request.params[:auth_token].present?
        user = ApiKey.find_by(access_token: request.params[:auth_token]).try(:user)
        if user.blank?
          reject_unauthorized_connection
          return
        end

        return user
      end

      # cookie based (for web)
      user = User.find_by(id: cookies.signed['user.id'])
      if user && cookies.signed['user.expires_at'] > Time.now
        return user
      end

      reject_unauthorized_connection
    end
  end
end
