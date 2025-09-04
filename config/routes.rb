Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "task_lists#index", as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  # Fallback para helpers/redirects que usam root_path (Devise)
  root to: "task_lists#index"

  resources :task_lists do
    member { patch :update_task_status }
    resources :tasks
    resources :task_list_collaborators, path: "collaborators" do
      member do
        patch :accept
        patch :decline
      end
    end
  end

  resources :collaboration_invites, only: [ :index ], controller: "task_list_collaborator_invitations" do
    member do
      patch :accept
      patch :decline
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
