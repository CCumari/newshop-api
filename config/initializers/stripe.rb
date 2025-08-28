# Stripe configuration
Rails.application.configure do
  # Stripe API keys from environment variables
  config.stripe = {
    publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
    secret_key: ENV['STRIPE_SECRET_KEY'],
    endpoint_secret: ENV['STRIPE_ENDPOINT_SECRET']
  }
end

# Set Stripe API key
Stripe.api_key = Rails.application.config.stripe[:secret_key]
