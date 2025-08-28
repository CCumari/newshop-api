class Api::V1::CartsController < Api::V1::BaseController
  before_action :set_cart, only: [:show, :destroy]

  def index
    @carts = current_user.carts.includes(cart_items: :product)
    render json: @carts.as_json(
      include: { 
        cart_items: { 
          include: :product,
          methods: [:total_price]
        } 
      },
      methods: [:total_amount, :total_items]
    )
  end

  def show
    render json: @cart.as_json(
      include: { 
        cart_items: { 
          include: :product,
          methods: [:total_price]
        } 
      },
      methods: [:total_amount, :total_items]
    )
  end

  def create
    @cart = current_user.carts.create!
    render json: @cart, status: :created
  end

  def destroy
    @cart.destroy
    head :no_content
  end

  private

  def set_cart
    @cart = current_user.carts.find(params[:id])
  end
end
