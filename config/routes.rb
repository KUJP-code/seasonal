# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(/:locale)', locale: /ja|en/ do
    devise_for :users, path: 'auth'

    # Require users to be signed in to view these resources
    authenticate :user do
      resources :adjustments
      resources :areas
      resources :children
      resources :coupons
      resources :events
      resources :options
      resources :registrations
      resources :schools
      resources :time_slots
      resources :users

      # Ensures just the locale also goes to root
      get '/:locale', to: 'users#index'
    end
    get '/current_event', to: 'welcomes#current_event'
    get '/errors/permission', to: 'errors#permission'
  end

  # Defines the root path route ("/")
  authenticated :user do
    root to: 'users#index', as: :authenticated_root
  end
  root to: redirect('/auth/sign_in')
end
