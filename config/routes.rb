Rails.application.routes.draw do
  root "pages#home"

  get "blog/feed", to: "blog#feed"
  resources :blog, only: [ :index, :show ], param: :slug
  get "monitoring", to: "monitoring#index"
  get "about", to: "pages#about"

  get "up" => "rails/health#show", as: :rails_health_check
end
