Rails.application.routes.draw do
  resources :sites do
    resources :buildings do
      resources :floors do
        resources :rooms do
          resource :device_claim, only: %i[ new create ]
        end
      end
    end
  end
  resources :devices, only: %i[ index show ]

  root "organizations#show"
  resource :organization, only: [ :create, :edit, :update ]
  resource :session
  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  namespace :api do
    namespace :v1 do
      namespace :devices do
        resources :pairing_codes, only: :create
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
