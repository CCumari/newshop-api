module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    @current_user = User.find(decoded["user_id"])
  rescue
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
