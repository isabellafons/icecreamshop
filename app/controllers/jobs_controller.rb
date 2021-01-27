class JobsController < ApplicationController
    before_action :set_job, only: [:show, :edit, :update ,:destroy]
    before_action :check_login
    authorize_resource

    def index
        @active_jobs = Job.active.alphabetical.paginate(page: params[:page]).per_page(10)
        @inactive_jobs = Job.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
    end

    def show
    end

    def new
        @job = Job.new
    end

    def create
        @job = Job.new(job_params)
        if @job.save
          redirect_to jobs_path, notice: "Successfully added #{@job.name} ."
        else
          render action: 'new'
        end
    end

    def edit
    end

    def update
        if @job.update_attributes(job_params)
            redirect_to jobs_path, notice: "Updated #{@job.name}."
          else
            render action: 'edit'
          end
    end

    def destroy
        if @job.destroy
            flash[:notice] = "Removed #{@job.name}."
            redirect_to jobs_path, notice: "Removed job from the system."
        else
            flash[:notice] = "Cannot remove Job"
            render action: 'show'
        end
    end

    private

    def set_job
        @job = Job.find(params[:id])
    end

    def job_params
        params.require(:job).permit(:name, :description, :active) 
    end

end