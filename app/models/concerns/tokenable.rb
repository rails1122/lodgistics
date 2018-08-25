module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
  end

  def generate_token
    self.token = loop do
      random_token = rand.to_s[2..7]
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end
