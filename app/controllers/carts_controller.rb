class CartsController < ApplicationController
  include Authentication

  def index
    carts = current_user.carts.includes(:cart_items)
    render json: carts.as_json(include: { cart_items: { include: :product } })
  end
  

  def show
    cart = current_user.carts.find(params[:id])
    render json: cart.as_json(include: { cart_items: { include: :product } })
  end

  def create
    cart = current_user.carts.new
    if cart.save
      render json: cart, status: :created
    else
      render json: { errors: cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    cart = current_user.carts.find(params[:id])
    cart.destroy
    head :no_content
  end
end
