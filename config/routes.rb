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
    collection do
      post :notify_matched_user
    end
  end
  resources :bizcall_callbacks, only: [] do
    collection do
      post :user_call_failure_alert
      post :business_call_failure_alert
      post :business_call_apply_user_failure_alert
    end
  end
  resources :career_certifications, only: [] do
    member do
      post :notify
    end
  end
  resources :applies, only: [] do
    member do
      post :new_notification
    end
  end
  resources :point_histories do
    collection do
      post :add_point_changed_active_user
    end
  end
  post '/gamification/misson_complete', to: 'gamification#missionComplete'
end
