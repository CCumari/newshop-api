require 'jwt'

class AuthController < ApplicationController
  def signup
    user = User.new(user_params)
    if user.save
      UserMailer.confirmation_email(user).deliver_later
      render json: { message: "Signup successful. Please check your email to confirm." }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def confirm
    user = User.find_by(confirmation_token: params[:token])
    if user && !user.confirmed?
      user.confirm!
      render json: { message: "Account confirmed. You can now log in." }
    else
      render json: { error: "Invalid or expired token." }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.confirmed?
        render json: { token: generate_token(user.id) }
      else
        render json: { error: "Please confirm your account first." }, status: :unauthorized
      end
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def generate_token(user_id)
    payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
