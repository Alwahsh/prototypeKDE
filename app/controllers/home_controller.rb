class HomeController < ApplicationController
  def index
    @projects = Project.find(:all, :order => "id desc", :limit => 5)
  end
end
