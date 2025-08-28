class Api::V1::PaymentsController < Api::V1::BaseController
  before_action :set_order, only: [:index, :create, :show, :confirm, :cancel, :accept]
  before_action :set_payment, only: [:show, :confirm, :cancel, :accept]

  # GET /api/v1/orders/:order_id/payments
  def index
    @payments = @order.payments.includes(:refunds)
    render json: @payments.as_json(
      include: {
        refunds: {
          only: [:id, :amount, :status, :reason, :created_at]
        }
      },
      methods: [:refundable_amount, :total_refunded, :fully_refunded?]
    )
  end

  # GET /api/v1/orders/:order_id/payments/:id
  def show
    render json: @payment.as_json(
      include: {
        refunds: {
          only: [:id, :amount, :status, :reason, :created_at]
        }
      },
      methods: [:refundable_amount, :total_refunded, :fully_refunded?]
    )
  end

  # POST /api/v1/orders/:order_id/payments
  def create
    if @order.status != 'pending'
      return render json: { error: 'Order is not in pending status' }, status: :unprocessable_entity
    end

    # Create or get Stripe customer
    customer = StripeService.create_customer(current_user) if params[:save_payment_method]
    customer_id = customer&.id

    # Create payment intent
    result = StripeService.create_payment_intent(@order, customer_id)

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      # Update order status
      @order.update!(status: 'payment_pending')

      render json: {
        payment_intent: {
          id: result[:payment_intent].id,
          client_secret: result[:payment_intent].client_secret,
          status: result[:payment_intent].status,
          amount: result[:payment_intent].amount
        },
        payment: result[:payment].as_json(only: [:id, :amount, :status, :created_at])
      }, status: :created
    end
  end

  # POST /api/v1/orders/:order_id/payments/:id/confirm
  def confirm
    if @payment.status != 'pending'
      return render json: { error: 'Payment is not in pending status' }, status: :unprocessable_entity
    end

    payment_intent = StripeService.confirm_payment_intent(
      @payment.stripe_payment_intent_id, 
      params[:payment_method_id]
    )

    if payment_intent
      @payment.reload
      render json: {
        payment: @payment.as_json(only: [:id, :amount, :status, :payment_method]),
        payment_intent: {
          status: payment_intent.status,
          client_secret: payment_intent.client_secret
        }
      }
    else
      render json: { error: 'Failed to confirm payment' }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/orders/:order_id/payments/:id/accept
  # New route to directly accept payment without Stripe CLI
  def accept
    if @payment.status != 'pending' && @payment.status != 'requires_payment_method'
      return render json: { error: 'Payment cannot be accepted in current status' }, status: :unprocessable_entity
    end

    # Simulate payment success by triggering webhook manually
    begin
      # Update payment status directly (simulating webhook)
      @payment.update!(
        status: 'succeeded',
        payment_method: 'pm_card_visa_simulated'
      )

      # Update order status
      @order.update!(status: 'confirmed')

      # Clear the cart (same as webhook would do)
      cart = @order.user.current_cart
      cart.clear! unless cart.empty?

      render json: {
        message: 'Payment accepted successfully',
        payment: @payment.as_json(only: [:id, :amount, :status, :payment_method]),
        order: @order.as_json(only: [:id, :status, :order_number]),
        note: 'This simulates a successful payment for testing purposes'
      }
    rescue => e
      render json: { error: "Failed to accept payment: #{e.message}" }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/orders/:order_id/payments/:id/cancel
  def cancel
    if !['pending', 'requires_action'].include?(@payment.status)
      return render json: { error: 'Payment cannot be cancelled' }, status: :unprocessable_entity
    end

    payment_intent = StripeService.cancel_payment_intent(@payment.stripe_payment_intent_id)

    if payment_intent
      @payment.reload
      @order.update!(status: 'cancelled')
      
      render json: {
        message: 'Payment cancelled successfully',
        payment: @payment.as_json(only: [:id, :status]),
        order: @order.as_json(only: [:id, :status])
      }
    else
      render json: { error: 'Failed to cancel payment' }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Order not found' }, status: :not_found
  end

  def set_payment
    @payment = @order.payments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Payment not found' }, status: :not_found
  end

  def payment_params
    params.permit(:save_payment_method, :payment_method_id)
  end
end
