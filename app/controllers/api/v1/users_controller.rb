class Api::V1::UsersController < Api::V1::BaseController
  def profile
    render json: current_user.as_json(
      except: [:password_digest, :confirmation_token],
      methods: [:full_name]
    )
  end

  def show
    render json: current_user.as_json(
      except: [:password_digest, :confirmation_token],
      methods: [:full_name]
    )
  end

  def update
    if current_user.update(user_params)
      render json: current_user.as_json(
        except: [:password_digest, :confirmation_token],
        methods: [:full_name]
      )
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def orders
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

  def wishlist
    @wishlist_items = current_user.wishlist_items.includes(:product)
    render json: @wishlist_items.as_json(
      include: :product
    )
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :phone, :shipping_address, :billing_address)
  end
end
