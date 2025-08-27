class CartItemsController < ApplicationController
  include Authentication

  before_action :set_cart

  # POST /cart_items
  # params: { product_id: , quantity: (optional, default 1) }
  def create
    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    cart_item = @cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.quantity += (params[:quantity] || 1).to_i
    else
      cart_item = @cart.cart_items.build(product: product, quantity: (params[:quantity] || 1).to_i)
    end

    if cart_item.save
      render json: cart_item.as_json(include: :product), status: :created
    else
      render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cart_items/:id
  # Update quantity directly
  def update
    cart_item = @cart.cart_items.find_by(id: params[:id])
    return render json: { error: "Cart item not found" }, status: :not_found unless cart_item

    if params[:quantity].to_i <= 0
      cart_item.destroy
      head :no_content
    else
      if cart_item.update(quantity: params[:quantity])
        render json: cart_item.as_json(include: :product)
      else
        render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # DELETE /cart_items/:id
  def destroy
    cart_item = @cart.cart_items.find_by(id: params[:id])
    return render json: { error: "Cart item not found" }, status: :not_found unless cart_item

    cart_item.destroy
    head :no_content
  end

  private

  def set_cart
    # For simplicity, use the first cart of the user, or create one if none
    @cart = current_user.carts.first_or_create
  end
end
