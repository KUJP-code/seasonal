# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(/:locale)', locale: /ja|en/ do
    devise_for :users, path: 'auth'

    authenticate :user do
      resources :users
      resources :areas

      # Ensures just the locale also goes to root
      get '/:locale', to: 'users#index'
    end
    get '/current_event', to: 'welcomes#current_event'
  end

  # Defines the root path route ("/")
  authenticated :user do
    root to: 'users#index', as: :authenticated_root
  end
  root to: redirect('/auth/sign_in')
end
