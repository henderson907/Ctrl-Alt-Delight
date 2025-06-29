Rails.application.routes.draw do
  devise_for :views
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "pages#index"
  resources :webpages, only: [ :index, :show, :new, :create ]
  get "keyword_search", to: "webpages#keyword_search"
  post "keyword_search_results", to: "webpages#keyword_search_results"
end
