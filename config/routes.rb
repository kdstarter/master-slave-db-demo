Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#dashboard'
  get 'dashboard', to: 'home#dashboard'

  namespace :api do
    resources :dashboard, only: [:index]
    resources :products, only: [:index, :create]
    resources :orders, only: [:index, :create, :update]
  end
end
