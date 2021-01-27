class ShiftsController < ApplicationController
    before_action :set_shift, only: [:show, :edit, :update, :destroy]
    before_action :check_login
    authorize_resource
    def index
      get_index_data()
    end

    def show
        get_related_data()
    end
    
    def new
        @shift = Shift.new
       
    end

    def create
        @shift = Shift.new(shift_params)
        if @shift.save
          redirect_to shifts_path, notice: "Successfully added shift to #{@shift.assignment.employee.proper_name}."
        else
          render action: 'new'
        end
    end
   

    def edit
      get_related_data()
    end

    def update
        get_related_data()
        if @shift.update_attributes(shift_params)
            flash[:notice] = "Updated #{@shift.assignment.employee.proper_name}'s shift information."
            redirect_to @shift
        else
            render action: 'edit'
        end
    end

    def destroy
        if @shift.destroy
          get_index_data()
          redirect_to shifts_path, notice: "Removed shift from the system."
        else
          get_index_data()
          render action: 'show'
        end
    end

    def shift_button_in
      @shift =  Shift.find(params[:id])
      @time = TimeClock.new(@shift)
      if @shift.status ==  'pending'
        @time.start_shift_at()
        redirect_to home_path
      end
    end
  
    def shift_button_out
      @shift =  Shift.find(params[:id])
      @time = TimeClock.new(@shift)
      if @shift.status ==  'started'
        @time.end_shift_at()
        redirect_to home_path
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @shift = Shift.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:assignment_id, :date, :start_time, :end_time, :notes, :status)
    end

    def get_related_data
        @jobs = @shift.shift_jobs.map do |sj| sj.job end
        @shift_jobs = @shift.shift_jobs
    end

    def get_index_data
      if current_user.role?(:admin) 
        @upcoming_shifts = Shift.upcoming.chronological.paginate(page: params[:page]).per_page(10)
        @past_shifts = Shift.past.chronological.reverse_order.paginate(page: params[:page]).per_page(10)
      elsif current_user.role?(:manager)
        @upcoming_shifts = current_user.current_assignment.store.shifts.upcoming.chronological.paginate(page: params[:page]).per_page(10)
        @past_shifts = current_user.current_assignment.store.shifts.past.chronological.reverse_order.paginate(page: params[:page]).per_page(10)
      elsif current_user.role?(:employee)
        @upcoming_shifts = current_user.current_assignment.shifts.upcoming.chronological.paginate(page: params[:page]).per_page(10)
        @today_shifts = current_user.current_assignment.shifts.pending.for_next_days(0).chronological
        @past_shifts = current_user.current_assignment.shifts.past.chronological.reverse_order.paginate(page: params[:page]).per_page(10)
      end
      
    end
  
end