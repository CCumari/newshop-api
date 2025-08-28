class Api::V1::CheckoutController < Api::V1::BaseController
  def create
    cart = current_user.current_cart
    
    if cart.empty?
      return render json: { error: 'Cart is empty' }, status: :unprocessable_entity
    end

    # Validate stock availability
    cart.cart_items.each do |cart_item|
      unless cart_item.product.in_stock? && cart_item.product.stock_quantity >= cart_item.quantity
        return render json: { 
          error: "Insufficient stock for #{cart_item.product.name}",
          available_stock: cart_item.product.stock_quantity
        }, status: :unprocessable_entity
      end
    end

    # Create order
    order = current_user.orders.build(checkout_params)
    order.status = 'pending'
    order.total_amount = cart.total_amount

    if order.save
      # Create order items from cart items
      cart.cart_items.each do |cart_item|
        order.order_items.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end

      # Create payment intent through Stripe
      customer = StripeService.create_customer(current_user) if params[:save_payment_method]
      result = StripeService.create_payment_intent(order, customer&.id)

      if result[:error]
        # If payment intent creation fails, cleanup the order
        order.destroy
        return render json: { error: result[:error] }, status: :unprocessable_entity
      end

      # Update order status
      order.update!(status: 'payment_pending')

      render json: {
        checkout_session: {
          order_id: order.id,
          order_number: order.order_number,
          total_amount: order.total_amount,
          status: order.status,
          items: order.order_items.map do |item|
            {
              product_id: item.product.id,
              product_name: item.product.name,
              quantity: item.quantity,
              price: item.price,
              total: item.quantity * item.price
            }
          end,
          created_at: order.created_at,
          expires_at: 15.minutes.from_now
        },
        payment_intent: {
          id: result[:payment_intent].id,
          client_secret: result[:payment_intent].client_secret,
          amount: result[:payment_intent].amount,
          status: result[:payment_intent].status
        },
        message: 'Checkout session created. Complete payment within 15 minutes.'
      }, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    # For retrieving checkout session information
    order = current_user.orders.find(params[:id])
    payment = order.payments.first

    if payment
      payment_intent = StripeService.retrieve_payment_intent(payment.stripe_payment_intent_id)
      
      render json: { 
        checkout_session: {
          order_id: order.id,
          order_number: order.order_number,
          status: order.status,
          total_amount: order.total_amount,
          payment_status: payment.status,
          payment_intent: payment_intent ? {
            id: payment_intent.id,
            status: payment_intent.status,
            client_secret: payment_intent.client_secret
          } : nil
        }
      }
    else
      render json: { error: 'Payment not found for this order' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Checkout session not found' }, status: :not_found
  end

  private

  def checkout_params
    params.permit(:shipping_address, :billing_address)
  end
end
