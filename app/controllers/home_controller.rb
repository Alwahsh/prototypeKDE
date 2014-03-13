class HomeController < ApplicationController
  def index
    @projects = Project.find(:all, :order => "id desc", :limit => 5)
  end
  
  def general_report
    @stats = FbStats.find_by_project_id(0)
    @starting_date = @stats.start_date
    @facebook_posts = @stats.posts
    @fstarting_date = @stats.forum_start_date
    @forum_topics = @stats.forum_stats
    respond_to do |format|
      format.html # general_report.html.erb
      format.json { render json: @facebook_posts}
    end
  end
end
