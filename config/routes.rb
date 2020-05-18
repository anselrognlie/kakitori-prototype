Rails.application.routes.draw do
  resources :user_settings, only: []
  resources :users, only: %i[index]
  resources :kanjis, only: %i[index]
  root to: 'kanjis#index'
  get :login, to: 'users#select_user'
  get :error, to: 'pages#error'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
