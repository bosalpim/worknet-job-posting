Jets.application.routes.draw do
  resources :job_postings, only: :create
end
