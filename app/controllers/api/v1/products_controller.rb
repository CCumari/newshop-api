class Api::V1::ProductsController < Api::V1::BaseController
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :set_product, only: [:show, :update, :destroy, :toggle_wishlist]

  def index
    @products = Product.includes(:category, :product_variants)
    @products = @products.by_category(params[:category_id]) if params[:category_id].present?
    @products = @products.in_stock if params[:in_stock] == 'true'
    
    render json: @products.as_json(
      include: {
        category: { only: [:id, :name] },
        product_variants: { only: [:id, :name, :value, :price_modifier, :stock_quantity] }
      },
      methods: [:in_stock?]
    )
  end

  def show
    render json: @product.as_json(
      include: {
        category: { only: [:id, :name] },
        product_variants: { only: [:id, :name, :value, :price_modifier, :stock_quantity] }
      },
      methods: [:in_stock?]
    )
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  def toggle_wishlist
    wishlist_item = current_user.wishlist_items.find_by(product: @product)
    
    if wishlist_item
      wishlist_item.destroy
      render json: { message: 'Product removed from wishlist', wishlisted: false }
    else
      current_user.wishlist_items.create(product: @product)
      render json: { message: 'Product added to wishlist', wishlisted: true }
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.permit(:name, :price, :description, :stock_quantity, :sku, :category_id)
  end
end
