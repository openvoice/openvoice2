OpenVoice2::Application.routes.draw do
  resources :accounts

  root :to => 'home#show'
  resources :dials, :only => [:new, :create]
end
