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
      post :new_user_satisfaction_survey
    end
  end
  resources :bizcall_callbacks, only: [] do
    collection do
      post :user_call_failure_alert
      post :business_call_failure_alert
      post :business_call_apply_user_failure_alert
    end
  end
  resources :applies, only: [] do
    member do
      post :new_notification
    end
  end
  post '/gamification/misson_complete', to: 'gamification#missionComplete'
end
