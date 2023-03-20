# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(/:locale)', locale: /ja|en/ do
    devise_for :users, path: 'auth', controllers: {
      registrations: 'users/registrations'
    }

    # Require users to be signed in to view these resources
    authenticate :user do
      resources :adjustments
      resources :areas
      resources :children
      resources :coupons
      resources :events
      resources :invoices
      resources :notifications
      resources :options
      resources :price_lists
      resources :registrations
      resources :schools
      resources :time_slots
      resources :users

      # Routes for InvoiceEdits controller
      put 'copy_invoice', to: 'invoices#copy', as: :copy_invoice
      patch 'confirm_invoice', to: 'invoices#confirm', as: :confirm_invoice

      # Ensures just the locale also goes to root
      get '/:locale', to: 'users#profile'
    end
    get '/current_event', to: 'welcomes#current_event'
    get 'errors/child_theft', to: 'errors#child_theft', as: :child_theft
    get 'errors/permission', to: 'errors#permission', as: :no_permission
    get 'errors/registration_error', to: 'errors#registration_error', as: :reg_error
    get 'errors/required_user', to: 'errors#required_user', as: :required_user
    post 'user/add_child', to: 'users#add_child', as: :add_child
    post 'user/remove_child', to: 'users#remove_child', as: :remove_child
  end

  # Defines the root path route ("/")
  authenticated :user do
    root to: 'users#profile', as: :authenticated_root
  end
  root to: redirect('/auth/sign_in')
end
