Jets.application.routes.draw do
  resources :proposals, only: [] do
    member do
      post :new_notification
    end
  end
  resources :job_postings, only: :create do
    member do
      post :new_notification
    end
  end
end
