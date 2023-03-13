Jets.application.routes.draw do
  resources :proposals, only: [] do
    member do
      post :new_notification
      post :accepted
      post :rejected
    end
  end
  resources :job_postings, only: :create do
    member do
      post :new_notification
      post :new_satisfaction_survey
    end
  end
end
