class StaticPageController < ApplicationController
  def home
    render 'sessions/new'
  end
end
