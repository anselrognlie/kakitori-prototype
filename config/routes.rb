Rails.application.routes.draw do
  root to: 'kanjis#index'
  get 'users/pick', to: 'users#pick', as: :pick_user
  get 'users/:id/select', to: 'users#select', as: :select_user
  resources :user_settings, only: []
  resources :users, only: %i[show edit update index create]
  resources :kanjis, only: %i[index]
  get :error, to: 'pages#error'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
