Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'tokens/create'
      resources :users, only: [:show, :create, :update, :destroy]
      resources :tokens, only: [:create]
    end

  end
end
