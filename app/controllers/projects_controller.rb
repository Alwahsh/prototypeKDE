class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all.paginate(:page => params[:page],:per_page => 20)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    @bugs_by_state = @project.bugs_by_state
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bugs_by_state}
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new
    @projects = Project.find(:all, :order => "id desc", :limit => 10)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @projects = Project.find(:all, :order => "id desc", :limit => 10)
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
    respond_to do |format|
      if @project.save
	@project.fetch_project_repos
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
    @temp = @project.gitRepositories
    respond_to do |format|
      if @project.update_attributes(params[:project])
	if @temp != @project
	  @project.fetch_project_repos
	  Rails.cache.delete("commits_per_author"+@project.id.to_s)
	end
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  def bug
    @project = Project.find(params[:id])
    @bugs = @project.limited_bugs(params[:page],10)
    @numBugs = Array.new(@project.number_of_bugs,nil)
    @bugsPages = @numBugs.paginate(:page => params[:page],:per_page => 10)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bugs }
    end
  end
  
  def git
    @project = Project.find(params[:id])
    @git = @project.test_git
  end
  
  def mailList
    @project = Project.find(params[:id])
  end
  
  def ircChannel
    @project = Project.find(params[:id])
  end
  
end
