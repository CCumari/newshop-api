# Authentication routes below

Rails.application.routes.draw do
  post '/signup', to: 'auth#signup'
  post '/login', to: 'auth#login'
  get '/confirm', to: 'auth#confirm'

  resources :products
  resources :carts
  resources :cart_items, only: [:create, :update, :destroy]


  
end
