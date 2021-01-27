class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :search]
  before_action :check_login
  authorize_resource

  def index
   get_index_info

  end

  def show
    retrieve_employee_assignments
    retrieve_employee_shifts
  end

  def new
    @employee = Employee.new
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params)
   if @employee.save
       # if saved to database
       flash[:notice] = "Successfully added #{@employee.proper_name} as an employee."
       redirect_to employee_path(@employee) # go to show store page
    else
       # return to the 'new' form
       render action: 'new'
   end
end

  def update
    if @employee.update_attributes(employee_params)
      redirect_to @employee, notice: "Updated #{@employee.proper_name}'s information."
    else
      render action: 'edit'
    end
  end

  def destroy
    if @employee.destroy
      flash[:notice] = "Deleted #{@employee.proper_name} ."
      get_index_info()
     redirect_to employees_path
    else
      get_index_info
      retrieve_employee_assignments
      retrieve_employee_shifts
      flash[:notice] = "Cannot delete employee."
      render action: 'show'
    end
  end

  def show_week_pay
    @employee = Employee.find(params[:id])
    @payroll_calc = PayrollCalculator.new(DateRange.new(14.days.ago.to_date, 7.days.ago.to_date))
    @payroll = @payroll_calc.create_payroll_record_for(@employee)
    @pay_earned = @payroll.pay_earned
    render action: 'show_pay'
  end

  def show_pay
  end

  

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(:username, :first_name,:last_name,:ssn,:date_of_birth,:phone,:role,:active, :password, :password_confirmation)
  end

  def retrieve_employee_assignments
    @current_assignment = @employee.current_assignment
    @previous_assignments = @employee.assignments.to_a - [@current_assignment]
  end
  def retrieve_employee_shifts
    @upcoming_shifts = @employee.shifts.for_next_days(7).chronological
    @past_shifts = @employee.shifts.for_past_days(7).chronological
  end

  def get_index_info
    if current_user.role?(:admin) 
      @active_managers = Employee.managers.active.alphabetical.paginate(page: params[:page]).per_page(10)
      @active_employees = Employee.regulars.active.alphabetical.paginate(page: params[:page]).per_page(10)
      @inactive_employees = Employee.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
    elsif current_user.role?(:manager)
      @active_managers = current_user.current_assignment.store.employees.managers.active.alphabetical.paginate(page: params[:page]).per_page(10)
      @employee_ids = current_user.current_assignment.store.assignments.current.map{|a| a.employee_id}
      @active_employees = Employee.for_ids(@employee_ids).regulars.active.paginate(page: params[:page]).per_page(10)
      @inactive_employees = current_user.current_assignment.store.employees.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
    end
  end

end
