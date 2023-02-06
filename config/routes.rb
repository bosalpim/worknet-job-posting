Jets.application.routes.draw do
  resources :job_postings, only: :create do
    member do
      post :new_notification
    end
  end
end
