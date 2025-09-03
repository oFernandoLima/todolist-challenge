Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "task_lists#index", as: :authenticated_root
  end

  unauthenticated do
    root "devise/sessions#new", as: :unauthenticated_root
  end

  resources :task_lists do
    member { patch :update_task_status }
    resources :tasks
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
