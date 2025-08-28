class Api::V1::CategoriesController < Api::V1::BaseController
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :set_category, only: [:show]

  def index
    @categories = Category.includes(:products)
    render json: @categories.as_json(
      include: {
        products: {
          only: [:id, :name, :price, :stock_quantity],
          methods: [:in_stock?]
        }
      }
    )
  end

  def show
    render json: @category.as_json(
      include: {
        products: {
          only: [:id, :name, :price, :description, :stock_quantity],
          methods: [:in_stock?]
        }
      }
    )
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
end
