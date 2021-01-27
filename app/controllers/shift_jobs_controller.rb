class ShiftJobsController < ApplicationController
    before_action :set_shift_job, only: [:show, :edit, :update, :destroy]
    before_action :check_login
    authorize_resource

    def new
        @shift_job = ShiftJob.new
        @shift = Shift.find(params[:shift_id])
        
    end

    def create
        @shift_job = ShiftJob.new(shift_job_params)
        if @shift_job.save
            flash[:notice] = "Successfully updated shift job."
            redirect_to shift_path(@shift_job.shift)
        else
             @shift = Shift.find(params[:shift_job][:shift_id])
             render action: 'new', locals: { shift: @shift }
        end
    end

    def destroy
        if @shift_job.destroy
          flash[:notice] = "Successfully removed job from shift."
          redirect_to shift_path(@shift_job.shift)
        else
            redirect_to shifts_path
        end
      end

   
    private
    def set_shift_job
        @shift_job = ShiftJob.find(params[:id])
      end

    def shift_job_params
        params.require(:shift_job).permit(:shift_id, :job_id)
    end
end