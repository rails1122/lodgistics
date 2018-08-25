class Api::MentionsController < Api::BaseController
  include MentionsDoc

  skip_before_action :set_resource

  def index
    if params[:include_checked]
      @mentions = current_user.mentions.for_property_id(Property.current_id).order(id: :desc)
    else
      @mentions = current_user.mentions.not_checked.for_property_id(Property.current_id).order(id: :desc)
    end
  end

  def update
    @mention = Mention.find(params[:id])
    authorize! :read, @mention
    @mention.update(mention_params)
  end

  def snooze
    @mentions = @current_user.mentions.by_ids(params[:mention_ids]).unsnoozed_only
    now = DateTime.now
    @mentions.each do |i|
      i.snoozed_at = now
      i.save
    end
  end

  def unsnooze
    @mentions = @current_user.mentions.by_ids(params[:mention_ids]).snoozed_only
    @mentions.each do |i|
      i.snoozed_at = nil
      i.save
    end
  end

  def clear
    @mentions = @current_user.mentions.not_checked
    @mentions.each do |i|
      i.status = 'checked'
      i.save
    end
  end

  private

  def mention_params
    params.require(:mention).permit(:status)
  end

end
