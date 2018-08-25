class TwilioClient
  attr_accessor :client

  def initialize()
    account_sid = Settings.twilio_account_sid
    auth_token = Settings.twilio_auth_token
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def send_sms(to, body, from = Settings.twilio_from_number)
    begin
      @client.messages.create(
        from: from,
        to: to,
        body: body
      )
    rescue => e
      Airbrake.notify(e)
      Rails.logger.error "Failed to send SMS to #{to} - #{e.message}"
    end
  end
end
