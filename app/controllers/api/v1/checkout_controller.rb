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

    checkout_session = {
      id: SecureRandom.uuid,
      user_id: current_user.id,
      items: cart.cart_items.map do |item|
        {
          product_id: item.product.id,
          product_name: item.product.name,
          quantity: item.quantity,
          price: item.product.price,
          total: item.total_price
        }
      end,
      total_amount: cart.total_amount,
      created_at: Time.current,
      expires_at: 15.minutes.from_now
    }

    # In a real app, you'd store this in Redis or database
    # For now, we'll just return the session data
    render json: {
      checkout_session: checkout_session,
      message: 'Checkout session created. Complete payment within 15 minutes.'
    }, status: :created
  end

  def show
    # In a real app, you'd retrieve from Redis/database
    # For demo purposes, return mock data
    session_data = {
      id: params[:id],
      status: 'active',
      expires_at: 15.minutes.from_now,
      total_amount: current_user.current_cart.total_amount
    }

    render json: { checkout_session: session_data }
  end
end
