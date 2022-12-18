Rails.application.routes.draw do
  devise_for :users, path: "auth"

  authenticate :user do
    resources :users
  end

  # Defines the root path route ("/")
  authenticated :user do
    root to: "users#index", as: :authenticated_root
  end
  root to: redirect("/auth/sign_in")
end