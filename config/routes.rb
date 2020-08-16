# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'pages#home'
  get 'users/pick', to: 'users#pick', as: :pick_user
  get 'users/:id/select', to: 'users#select', as: :select_user
  resources :user_settings, only: []
  resources :users, only: %i[show edit update index create destroy]
  resources :kanjis, only: %i[index]
  resources :settings, only: %i[index]
  put :settings, to: 'settings#update'
  get :error, to: 'pages#error'
  get 'api/v1/wk_register/:token', to: 'wk#register'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
