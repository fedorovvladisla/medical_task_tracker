Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :tasks do
        resources :tags, only: [:create, :destroy], controller: 'tags'
        resources :occurrences, only: [:update], param: :date, controller: 'occurrences'
      end
    end
  end
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end