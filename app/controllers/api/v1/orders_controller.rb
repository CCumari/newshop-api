class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :cancel, :update_status]

  def index
    @orders = current_user.orders.includes(:order_items).recent
    render json: @orders.as_json(
      include: {
        order_items: {
          include: :product
        }
      },
      methods: [:order_number, :total_items]
    )
  end

  def show
    render json: @order.as_json(
      include: {
        order_items: {
          include: :product,
          methods: [:total_price]
        }
      },
      methods: [:order_number, :total_items, :can_be_cancelled?]
    )
  end

  def create
    cart = current_user.current_cart
    
    if cart.empty?
      return render json: { error: 'Cart is empty' }, status: :unprocessable_entity
    end

    @order = current_user.orders.build(order_params)
    @order.status = 'pending'
    @order.total_amount = cart.total_amount

    if @order.save
      # Create order items from cart items
      cart.cart_items.each do |cart_item|
        @order.order_items.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end

      # Update product stock
      cart.cart_items.each do |cart_item|
        product = cart_item.product
        product.update!(stock_quantity: product.stock_quantity - cart_item.quantity)
      end

      # Clear the cart
      cart.clear!

      render json: @order.as_json(
        include: {
          order_items: {
            include: :product,
            methods: [:total_price]
          }
        },
        methods: [:order_number]
      ), status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def cancel
    if @order.can_be_cancelled?
      @order.update!(status: 'cancelled')
      
      # Restore stock
      @order.order_items.each do |order_item|
        product = order_item.product
        product.update!(stock_quantity: product.stock_quantity + order_item.quantity)
      end

      render json: { message: 'Order cancelled successfully' }
    else
      render json: { error: 'Order cannot be cancelled' }, status: :unprocessable_entity
    end
  end

  def update_status
    if params[:status].present? && Order.statuses.key?(params[:status])
      @order.update!(status: params[:status])
      render json: @order.as_json(methods: [:order_number])
    else
      render json: { error: 'Invalid status' }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.permit(:shipping_address, :billing_address)
  end
end
