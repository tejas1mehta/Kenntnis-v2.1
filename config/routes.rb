Quora::Application.routes.draw do
  root to: 'static_pages#root'

  namespace :api, defaults: { format: :json } do
    resource :session, only: [:create, :destroy]
    resources :users, only: [:create, :show, :update] do
      get :activate, on: :collection
      get :feed, on: :member
      get :questions_created, on: :member
      get :answers_created, on: :member
      get :followings, on: :member
      get :followers, on: :member
      get :userinfo, on: :member
      get :search, on: :collection

    end

    resources :messages, only: [:create, :index,:show]

    resources :notifications, only: [:create, :index]

    resources :questions, except: [:index] do
      resources :answers, except: [:create, :destroy, :update]
    end

    resources :upvotes, only: [:create, :destroy]

    resources :followings, only: [:create, :destroy]

    resources :answers, only: [:create, :destroy, :update]

    resources :topics

    resources :comments, only: [:create, :destroy]
  end
end
