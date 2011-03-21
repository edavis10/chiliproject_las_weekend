class MyTravelRequestsController < ApplicationController
  unloadable

  def index
    render :text => "Hi y'all"
  end
end
