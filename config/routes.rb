OpenVoice2::Application.routes.draw do
  resources :endpoints, :only => [:new, :create]

  resources :accounts
  resources :sessions, :only => [:new, :create, :destroy]

  root :to => 'home#show'
  resources :dials, :only => [:new, :create]
end
