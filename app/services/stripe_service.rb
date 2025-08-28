class StripeService
  class << self
    # Create a customer in Stripe
    def create_customer(user)
      customer = Stripe::Customer.create({
        email: user.email,
        name: user.full_name,
        metadata: {
          user_id: user.id
        }
      })
      
      # Update user with Stripe customer ID if you want to store it
      # user.update(stripe_customer_id: customer.id)
      
      customer
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe customer creation failed: #{e.message}"
      nil
    end

    # Create payment intent
    def create_payment_intent(order, customer_id = nil)
      payment_intent_params = {
        amount: (order.total_amount * 100).to_i, # Stripe uses cents
        currency: 'usd',
        automatic_payment_methods: { 
          enabled: true,
          allow_redirects: 'never'  # Disable redirect-based payment methods for testing
        },
        metadata: {
          order_id: order.id,
          order_number: order.order_number,
          user_id: order.user_id
        }
      }

      payment_intent_params[:customer] = customer_id if customer_id

      payment_intent = Stripe::PaymentIntent.create(payment_intent_params)
      
      # Create payment record
      payment = order.payments.create!(
        stripe_payment_intent_id: payment_intent.id,
        amount: order.total_amount,
        status: payment_intent.status,
        stripe_customer_id: customer_id
      )

      { payment_intent: payment_intent, payment: payment }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe payment intent creation failed: #{e.message}"
      { error: e.message }
    end

    # Confirm payment intent
    def confirm_payment_intent(payment_intent_id, payment_method_id = nil)
      params = {}
      params[:payment_method] = payment_method_id if payment_method_id

      payment_intent = Stripe::PaymentIntent.confirm(payment_intent_id, params)
      
      # Update payment record
      payment = Payment.find_by(stripe_payment_intent_id: payment_intent_id)
      if payment
        payment.update!(
          status: payment_intent.status,
          payment_method: payment_method_id
        )
      end

      payment_intent
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe payment confirmation failed: #{e.message}"
      nil
    end

    # Create refund
    def create_refund(payment, amount, reason = nil)
      refund_params = {
        payment_intent: payment.stripe_payment_intent_id,
        amount: (amount * 100).to_i, # Stripe uses cents
        metadata: {
          order_id: payment.order_id,
          payment_id: payment.id
        }
      }

      refund_params[:reason] = reason if reason

      stripe_refund = Stripe::Refund.create(refund_params)
      
      # Create refund record
      refund = payment.refunds.create!(
        order: payment.order,
        amount: amount,
        status: stripe_refund.status,
        stripe_refund_id: stripe_refund.id,
        reason: reason || 'requested_by_customer'
      )

      { stripe_refund: stripe_refund, refund: refund }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe refund creation failed: #{e.message}"
      { error: e.message }
    end

    # Retrieve payment intent
    def retrieve_payment_intent(payment_intent_id)
      Stripe::PaymentIntent.retrieve(payment_intent_id)
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to retrieve payment intent: #{e.message}"
      nil
    end

    # Cancel payment intent
    def cancel_payment_intent(payment_intent_id)
      payment_intent = Stripe::PaymentIntent.cancel(payment_intent_id)
      
      # Update payment record
      payment = Payment.find_by(stripe_payment_intent_id: payment_intent_id)
      payment&.update!(status: 'cancelled')

      payment_intent
    rescue Stripe::StripeError => e
      Rails.logger.error "Failed to cancel payment intent: #{e.message}"
      nil
    end
  end
end
