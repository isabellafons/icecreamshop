class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :terminate, :destroy]
  before_action :check_login
  authorize_resource

  def index
    if current_user.role?(:admin)
      @current_assignments = Assignment.current.chronological.paginate(page: params[:page]).per_page(10)
      @past_assignments = Assignment.past.chronological.paginate(page: params[:page]).per_page(10)
    else
      @current_assignments = current_user.current_assignment.store.assignments.current.chronological.paginate(page: params[:page]).per_page(10)
      @past_assignments = current_user.current_assignment.store.assignments.past.chronological.paginate(page: params[:page]).per_page(10)
    end
  end

  def show
    @shift_list = (@assignment.shifts.pending + @assignment.shifts.finished)
    
  end

  def new
    @assignment = Assignment.new
    @assignment.employee_id = params[:employee_id] unless params[:employee_id].nil?
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      redirect_to assignments_path, notice: "Successfully added the assignment."
    else
      render action: 'new'
    end
  end

  def terminate
    if @assignment.terminate
      redirect_to assignments_path, notice: "Assignment for #{@assignment.employee.proper_name} terminated."
    end
  end

  def destroy
    if @assignment.destroy
     redirect_to assignments_path, notice: "Removed assignment from the system."
    else
      render action: 'show'
    end
  end

  def edit
  end

  def update
    if @assignment.update_attributes(assignment_params)
      flash[:notice] = "Successfully updated assignemnt for #{@assignment.employee.proper_name} ."
      redirect_to @assignment
    else
      render action: 'edit'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def assignment_params
    params.require(:assignment).permit(:store_id, :employee_id, :start_date, :end_date, :pay_grade_id)
  end

end

