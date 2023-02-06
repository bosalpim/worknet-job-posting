Jets.application.routes.draw do
  get 'proposals/create'
  resources :job_postings, only: :create do
    member do
      post :new_notification
    end
  end
end
