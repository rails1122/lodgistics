class ApiKey < ApplicationRecord
  belongs_to :user
  before_create :generate_access_token

  private

  def self.clear_user_access_tokens(user)
    ApiKey.where(user: user).destroy_all
  end

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
