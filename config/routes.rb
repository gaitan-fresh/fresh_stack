Rails.application.routes.draw do
  root "questions#index"

  # Active Storage routes are automatically included in Rails 8
  # No need to manually define them unless customization is needed

  # Authentication routes
  resources :sessions, only: [ :new, :create, :destroy ]
  resources :users, only: [ :new, :create, :show ]
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "/signup", to: "users#new"

  # Main resources
  resources :questions do
    resources :responses, except: [ :index, :show ]
    member do
      post :vote_up
      post :vote_down
      post :summarize
    end
    collection do
      get :search
    end
  end

  resources :responses, only: [ :edit, :update, :destroy ] do
    resources :responses, except: [ :index, :show ]
    member do
      post :vote_up
      post :vote_down
      patch :accept
    end
  end

  resources :blogs do
    member do
      post :vote_up
      post :vote_down
      post :summarize
    end
    collection do
      get :search
    end
  end

  resources :tags, only: [ :index, :show ]

  # Image handling routes
  resources :images, only: [ :create, :show, :destroy ] do
    collection do
      post :batch_upload
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
