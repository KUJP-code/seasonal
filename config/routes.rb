# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(/:locale)', locale: /ja|en/ do
    devise_for :users, path: 'auth', controllers: {
      registrations: 'users/registrations'
    }

    # Require users to be signed in to view these resources
    authenticate :user do
      resources :adjustments, only: %i[edit]
      resources :charts, only: %i[show index]
      resources :children
      resources :csvs, only: %i[index]
      resources :events
      resources :invoices, except: %i[create edit new]
      resources :price_lists, except: %i[show]
      resources :time_slots, except: %i[create destroy new]
      resources :users

      # Mailer subscription routes
      resources :mailer_subscriptions, only: %i[index create update]

      # Non-REST routes for Children controller
      get 'child/find_child', to: 'children#find_child', as: :find_child

      # Non-REST routes for CSVs controller
      post 'csv/upload', to: 'csvs#upload', as: :upload_csv
      post 'csv/update', to: 'csvs#update', as: :update_csv
      get 'csv/download', to: 'csvs#download', as: :download_csv

      # Non-REST routes for Events controller
      get 'event/diff_school', to: 'events#show', as: :diff_school_path

      # Non-REST routes for Invoices controller
      patch 'confirm_invoice', to: 'invoices#confirm', as: :confirm_invoice
      get 'confirm_invoice', to: 'invoices#confirmed', as: :confirmed_invoice
      put 'copy_invoice', to: 'invoices#copy', as: :copy_invoice
      post 'merge_invoices', to: 'invoices#merge', as: :merge_invoices
      post 'seen_invoice', to: 'invoices#seen', as: :seen_invoice

      # Non-REST routes for Users controller
      post 'user/add_child', to: 'users#add_child', as: :add_child
      post 'user/remove_child', to: 'users#remove_child', as: :remove_child
      post 'user/merge_children', to: 'users#merge_children', as: :merge_children

      # Ensures just the locale also goes to root
      get '/:locale', to: 'users#profile'
    end
  end

  # Health check endpoint for EB load balancer
  get '/health_check', to: proc { [200, {}, ['success']] }

  # Route to auto-unsubscribe from emails
  resources :mailer_subscription_unsubcribes, only: %i[show update]

  # Defines the root path route ("/")
  authenticated :user do
    root to: 'users#profile', as: :authenticated_root
  end
  root to: 'splashes#landing'
end
