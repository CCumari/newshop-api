class Api::V1::WebhooksController < ApplicationController
  # No authentication needed for webhooks - we verify Stripe signature instead
  before_action :verify_stripe_signature

  def stripe
    case @event.type
    when 'payment_intent.succeeded'
      handle_payment_succeeded(@event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failed(@event.data.object)
    when 'payment_intent.canceled'
      handle_payment_canceled(@event.data.object)
    when 'payment_intent.requires_action'
      handle_payment_requires_action(@event.data.object)
    when 'charge.dispute.created'
      handle_dispute_created(@event.data.object)
    when 'refund.created'
      handle_refund_created(@event.data.object)
    when 'refund.updated'
      handle_refund_updated(@event.data.object)
    else
      Rails.logger.info "Unhandled Stripe webhook event: #{@event.type}"
    end

    render json: { status: 'success' }
  rescue => e
    Rails.logger.error "Stripe webhook error: #{e.message}"
    render json: { error: 'Webhook processing failed' }, status: :bad_request
  end

  private

  def verify_stripe_signature
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.config.stripe[:endpoint_secret]

    begin
      @event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      Rails.logger.error 'Invalid JSON payload in Stripe webhook'
      render json: { error: 'Invalid payload' }, status: :bad_request and return
    rescue Stripe::SignatureVerificationError
      Rails.logger.error 'Invalid signature in Stripe webhook'
      render json: { error: 'Invalid signature' }, status: :bad_request and return
    end
  end

  def handle_payment_succeeded(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment

    payment.update!(
      status: 'succeeded',
      payment_method: payment_intent.payment_method
    )

    # Update order status
    order = payment.order
    order.update!(status: 'confirmed')

    # Send confirmation email
    # UserMailer.order_confirmation(order).deliver_later

    Rails.logger.info "Payment succeeded for order #{order.order_number}"
  end

  def handle_payment_failed(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment

    payment.update!(
      status: 'failed'
    )

    # Update order status
    order = payment.order
    order.update!(status: 'cancelled')

    # Restore stock
    restore_order_stock(order)

    Rails.logger.info "Payment failed for order #{order.order_number}"
  end

  def handle_payment_canceled(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment

    payment.update!(status: 'cancelled')

    # Update order status and restore stock
    order = payment.order
    order.update!(status: 'cancelled')
    restore_order_stock(order)

    Rails.logger.info "Payment canceled for order #{order.order_number}"
  end

  def handle_payment_requires_action(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment

    payment.update!(status: 'requires_action')
    Rails.logger.info "Payment requires action for order #{payment.order.order_number}"
  end

  def handle_dispute_created(charge)
    # Handle dispute/chargeback created
    Rails.logger.warn "Dispute created for charge: #{charge.id}"
    
    # You could create a Dispute model to track these
    # Or send notifications to admins
  end

  def handle_refund_created(refund)
    # Update refund status when created in Stripe
    our_refund = Refund.find_by(stripe_refund_id: refund.id)
    return unless our_refund

    our_refund.update!(status: refund.status)
    Rails.logger.info "Refund created: #{refund.id} - Status: #{refund.status}"
  end

  def handle_refund_updated(refund)
    # Update refund status when updated in Stripe
    our_refund = Refund.find_by(stripe_refund_id: refund.id)
    return unless our_refund

    our_refund.update!(status: refund.status)

    # If refund succeeded, check if order should be marked as refunded
    if refund.status == 'succeeded'
      payment = our_refund.payment
      if payment.fully_refunded?
        payment.order.update!(status: 'refunded')
      end
    end

    Rails.logger.info "Refund updated: #{refund.id} - Status: #{refund.status}"
  end

  def restore_order_stock(order)
    order.order_items.each do |order_item|
      product = order_item.product
      product.update!(
        stock_quantity: product.stock_quantity + order_item.quantity
      )
    end
  end
end
