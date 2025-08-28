class Api::V1::RefundsController < Api::V1::BaseController
  before_action :set_order
  before_action :set_payment, only: [:create]
  before_action :set_refund, only: [:show, :cancel]

  # GET /api/v1/orders/:order_id/refunds
  def index
    @refunds = @order.refunds.includes(:payment)
    render json: @refunds.as_json(
      include: {
        payment: {
          only: [:id, :amount, :status, :stripe_payment_intent_id]
        }
      },
      methods: [:refund_percentage, :partial_refund?]
    )
  end

  # GET /api/v1/orders/:order_id/refunds/:id
  def show
    render json: @refund.as_json(
      include: {
        payment: {
          only: [:id, :amount, :status, :stripe_payment_intent_id]
        }
      },
      methods: [:refund_percentage, :partial_refund?]
    )
  end

  # POST /api/v1/orders/:order_id/payments/:payment_id/refunds
  def create
    unless @payment.can_be_refunded?
      return render json: { 
        error: 'Payment cannot be refunded',
        reason: @payment.succeeded? ? 'No refundable amount remaining' : 'Payment not successful'
      }, status: :unprocessable_entity
    end

    amount = params[:amount].present? ? params[:amount].to_f : @payment.refundable_amount
    reason = params[:reason] || 'requested_by_customer'

    if amount > @payment.refundable_amount
      return render json: { 
        error: "Refund amount cannot exceed refundable amount of #{@payment.refundable_amount}" 
      }, status: :unprocessable_entity
    end

    # Create refund through Stripe
    result = StripeService.create_refund(@payment, amount, reason)

    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      refund = result[:refund]
      
      # Update order status if fully refunded
      if @payment.reload.fully_refunded?
        @order.update!(status: 'refunded')
      end

      render json: {
        refund: refund.as_json(methods: [:refund_percentage, :partial_refund?]),
        order: @order.as_json(only: [:id, :status]),
        payment: @payment.as_json(
          only: [:id, :amount, :status],
          methods: [:refundable_amount, :total_refunded, :fully_refunded?]
        )
      }, status: :created
    end
  end

  # POST /api/v1/orders/:order_id/refunds/:id/cancel
  def cancel
    unless @refund.pending?
      return render json: { error: 'Only pending refunds can be cancelled' }, status: :unprocessable_entity
    end

    # In a real implementation, you would cancel the refund in Stripe
    # For now, we'll just update the status
    @refund.update!(status: 'cancelled')

    render json: {
      message: 'Refund cancelled successfully',
      refund: @refund.as_json(only: [:id, :amount, :status])
    }
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Order not found' }, status: :not_found
  end

  def set_payment
    @payment = @order.payments.find(params[:payment_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Payment not found' }, status: :not_found
  end

  def set_refund
    @refund = @order.refunds.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Refund not found' }, status: :not_found
  end

  def refund_params
    params.permit(:amount, :reason)
  end
end
