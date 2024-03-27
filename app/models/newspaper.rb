class Newspaper < ApplicationRecord
  enum status: {
    pending: 'pending',
    processing: 'processing',
    done: 'done'
  }
  
  belongs_to :user
end
