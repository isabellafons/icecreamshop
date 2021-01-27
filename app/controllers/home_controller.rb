class HomeController < ApplicationController
  #include services 
  
  #authorize_resource :class => false
  def index
    retrieve_needed_info()
    show_pay_home()
    get_missed_employees()
  end

  def about
  end

  def contact
  end

  def privacy
  end

  


  def retrieve_needed_info
    @active_stores = Store.active.alphabetical
    @active_employees = Employee.active.alphabetical
    if !(current_user.nil?)
      if current_user.role?(:admin) 
      @active_employees = Employee.active.alphabetical
      @pay_grades = PayGrade.alphabetical
      elsif current_user.role?(:manager) 
        @active_employees = current_user.current_assignment.store.shifts.for_next_days(7).map{|s| s.employee}.uniq.sort
      end 
    end
    
    if !current_user.nil?
      if current_user.role?(:admin) 
        @upcoming_shifts = Shift.upcoming.for_next_days(7).chronological.paginate(page: params[:page]).per_page(10)
        @past_incomplete = Shift.for_past_days(7).pending
      elsif  current_user.role?(:manager)
        @upcoming_shifts = current_user.current_assignment.store.shifts.upcoming.for_next_days(7).chronological.paginate(page: params[:page]).per_page(10)
        @past_incomplete = current_user.current_assignment.store.shifts.for_past_days(7).pending
        @past = current_user.current_assignment.store.shifts.past.for_past_days(7).chronological.paginate(page: params[:page]).per_page(10)
        @today_shifts = current_user.current_assignment.shifts.pending.for_next_days(0).chronological
        @started_shifts = current_user.current_assignment.shifts.started.for_next_days(0).chronological
      elsif current_user.role?(:employee)
        @upcoming_shifts = current_user.current_assignment.shifts.upcoming.chronological.paginate(page: params[:page]).per_page(10)
        @today_shifts = current_user.current_assignment.shifts.pending.for_next_days(0).chronological
        @started_shifts = current_user.current_assignment.shifts.started.for_next_days(0).chronological
     end
    end
  end

  def get_missed_employees
    @missed_employees = []
    for employee in @active_employees
      if(!(employee.shifts.for_past_days(7).past.pending.size == 0 )&& !employee.current_assignment.nil?)
        @missed_employees << employee
      end
    end
  end

  def search
    redirect_back(fallback_location: employees_path) if params[:query].blank?
    @query = params[:query]
    if current_user.role?(:admin)
      @employees = Employee.search_employee(@query)
      @total_hits = @employees.size
    elsif current_user.role?(:manager)
      @employees = current_user.current_assignment.store.employees.search_employee(@query)
      @total_hits = @employees.size
    end
    if(@total_hits == 1)
      redirect_to employee_path(@employees.first)
    end
  end

  def show_pay_home
    if !current_user.nil?
      @employee = current_user
      @payroll_calc = PayrollCalculator.new(DateRange.new(14.days.ago.to_date, 7.days.ago.to_date))
      @payroll = @payroll_calc.create_payroll_record_for(@employee)
      @pay_earned = @payroll.pay_earned
    end
  end


  
end