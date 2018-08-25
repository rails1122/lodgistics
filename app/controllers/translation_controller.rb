class TranslationController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    text = Translation.auto_translate(params[:text])
    render json: {text: text}
  end

end
