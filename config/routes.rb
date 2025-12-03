Rails.application.routes.draw do
  resources :notifications, only: [:index, :show]
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "dashboard", to: "pages#dashboard"
  resources :partnership_topics, only: [:update] do
    member do
      patch :complete_topic
    end
  end
  resources :topics, only: [:index, :show] do
    resources :partnership_topics, only: [:create]
    collection do
      post :generate
    end
  end
  resources :journals, only: [:update, :edit] do
    resources :comments, only: [:create]
    member do
      patch :add_audio
      patch :complete_conversation
      post :remind_partner # New route for sending reminders
    end
  end
  resources :grammar_points, only: [:show]
  resources :challenges, only: [:show] do
    resources :journals, only: [:new, :create]
  end
  resources :partnerships, only: [:new, :create] do
    resources :journals, only: [:index, :show]
  end
end
