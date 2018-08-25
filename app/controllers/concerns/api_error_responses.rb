module ApiErrorResponses
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from CanCan::AccessDenied, with: :render_access_denied
    rescue_from ArgumentError, with: :render_argument_error
    rescue_from ActiveRecord::RecordInvalid, with: :render_422

    def render_422(e)
      render json: {error: e.message, error_message: e.message}, status: 422
    end

    def render_access_denied(e)
      render json: {error: e.message, error_message: e.message}, status: 401
    end

    def render_unauthorized(errors = {})
      @api_errors = errors
      render json: {errors: @api_errors}, status: 401
    end

    def render_error(errors = {})
      @api_errors = errors || ''
      render json: {errors: @api_errors}, status: 400
    end

    def render_not_found(e)
      error = e.message || 'not found'
      render json: {error: error, error_message: error}, status: 404
    end

    def render_argument_error(e)
      error = e.message || 'check your parameter'
      render json: { error: error, error_message: error }, status: 422
    end

    def render_no_content
      render json: '', status: :no_content
    end
  end
end
