class Api::V1::CartItemsController < Api::V1::BaseController
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  def index
    render json: @cart.cart_items.includes(:product).as_json(
      include: :product,
      methods: [:total_price]
    )
  end

  def create
    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    @cart_item = @cart.cart_items.find_by(product_id: product.id)

    if @cart_item
      @cart_item.quantity += (params[:quantity] || 1).to_i
    else
      @cart_item = @cart.cart_items.build(product: product, quantity: (params[:quantity] || 1).to_i)
    end

    if @cart_item.save
      render json: @cart_item.as_json(include: :product, methods: [:total_price]), status: :created
    else
      render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if params[:quantity].to_i <= 0
      @cart_item.destroy
      head :no_content
    else
      if @cart_item.update(quantity: params[:quantity])
        render json: @cart_item.as_json(include: :product, methods: [:total_price])
      else
        render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @cart_item.destroy
    head :no_content
  end

  private

  def set_cart
    @cart = current_user.current_cart
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end
