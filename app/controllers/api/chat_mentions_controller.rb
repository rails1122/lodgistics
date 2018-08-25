class Api::ChatMentionsController < Api::BaseController
  include ChatMentionsDoc

  skip_before_action :set_resource

  def update
    @chat_mention = Mention.find(params[:id])
    authorize! :read, @chat_mention
    @chat_mention.update(chat_mention_params)
  end

  private

  def chat_mention_params
    params.require(:chat_mention).permit(:status)
  end
end
