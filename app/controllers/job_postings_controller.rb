class JobPostingsController < ApplicationController
  def create
    GetWorknetJobService.call
  end
end
