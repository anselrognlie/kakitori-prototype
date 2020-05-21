Rails.application.routes.draw do
  resources :user_settings, only: []
  resources :users, only: %i[show edit update]
  resources :kanjis, only: %i[index]
  root to: 'kanjis#index'
  get :select_user, to: 'users#select_user', as: :select_user
  get :error, to: 'pages#error'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
