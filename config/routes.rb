Jets.application.routes.draw do
  resources :proposals, only: [] do
    member do
      post :new_notification
      post :rejected
      post :new_v2
      post :accepted_v2

    end
  end
  resources :job_postings, only: :create do
    member do
      post :new_notification
      post :job_ads_messages
    end
    collection do
      post :notify_matched_user
      post :new_saved_job_posting_user
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
      post :confirm
    end
  end
  resources :applies, only: [] do
    member do
      post :new_notification
    end
  end
  resources :users, only: [] do
    member do
      post :notify_comment
    end
    collection do
      post :active_service_guide
      post :receive_roulette_ticket
    end
  end
  resources :job_applications, only: [] do
    member do
      post :new_application
    end
  end
  resources :contact_messages, only: [] do
    member do
      post :new_contact_message
    end
  end
  resources :none_ltc, only: [] do
    collection do
      post :new_none_ltc_request
    end
  end

  post '/notification', to: 'notification#send_message'
  post '/notification/ask_active', to: 'notification#ask_active'
  post '/notification/sms', to: 'notification#sms'
  post '/point_histories/add_point_changed_active_user', to: 'point_histories#add_point_changed_active_user'
  post '/gamification/misson_complete', to: 'gamification#missionComplete'
  post '/push_alerts/prepare_academy_boost', to: 'push_alerts#prepare_academy_boost'
  get '/push_leaderboard', to: 'push_alerts#leaderboard'
end

# updated by jets upgrade
