class Api::AcknowledgementsController < Api::BaseController
  include AcknowledgementsDoc

  skip_before_action :set_resource

  load_and_authorize_resource only: [ :show, :index, :create, :check, :received, :sent ]

  def create
    if @acknowledgement.save!
      snooze_param = params[:acknowledgement][:snooze_mention]
      snooze_mention = (snooze_param == 'true') || (snooze_param == '1')
      @acknowledgement.acknowledeable.mentions.map(&:set_snooze) unless snooze_mention
      AcknowledgementNotificationService.new.execute(@acknowledgement)
    end
  end

  def check
    @acknowledgement.check
  end

  private

  def acknowledgement_params
    params.require(:acknowledgement).permit(:target_user_id, :acknowledeable_id, :acknowledeable_type)
  end

end
