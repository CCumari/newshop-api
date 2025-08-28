Rails.application.routes.draw do
  # Health check
  get '/up', to: 'rails/health#show', as: :rails_health_check

  # API versioning
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post '/signup', to: 'auth#signup'
      post '/login', to: 'auth#login'
      get '/confirm', to: 'auth#confirm'

      # Core resources
      resources :products do
        member do
          post :toggle_wishlist
        end
      end
      
      resources :carts do
        resources :cart_items, only: [:index, :create, :update, :destroy]
      end
      
      # User-specific routes
      resources :users, only: [:show, :update] do
        member do
          get :profile
          get :orders
          get :wishlist
        end
      end

      # Order management
      resources :orders, only: [:index, :show, :create] do
        member do
          patch :cancel
          patch :update_status
        end
        
        # Payment routes nested under orders
        resources :payments, only: [:index, :show, :create] do
          member do
            post :confirm
            post :cancel
            post :accept
          end
          
          # Refund routes nested under payments
          resources :refunds, only: [:create]
        end
        
        # Direct refund routes under orders
        resources :refunds, only: [:index, :show] do
          member do
            post :cancel
          end
        end
      end

      # Categories for better product organization
      resources :categories, only: [:index, :show] do
        resources :products, only: [:index]
      end

      # Checkout flow
      post '/checkout', to: 'checkout#create'
      get '/checkout/session/:id', to: 'checkout#show'

      # Webhook routes (no authentication required)
      post '/webhooks/stripe', to: 'webhooks#stripe'
    end
  end

  # Fallback for unversioned requests (redirect to v1)
  post '/signup', to: redirect('/api/v1/signup')
  post '/login', to: redirect('/api/v1/login')
  get '/confirm', to: redirect('/api/v1/confirm')
  resources :products, only: [] do
    collection do
      get '', to: redirect('/api/v1/products')
    end
  end
end
