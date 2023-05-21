Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'moon#index'
  get 'weather', to: 'weather#previsao', as: 'previsao'

end
