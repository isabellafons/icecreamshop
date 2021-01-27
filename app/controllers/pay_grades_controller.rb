class PayGradesController < ApplicationController
    before_action :set_pay_grades, only: [:show, :edit, :update]
    before_action :check_login
    authorize_resource

    def index
        @active_pay_grades = PayGrade.active.alphabetical.paginate(page: params[:page]).per_page(10)
        @inactive_pay_grades = PayGrade.inactive.alphabetical.paginate(page: params[:page]).per_page(10)
    end


    def show
        #show payrates
        @pay_rates = @pay_grade.pay_grade_rates.chronological
    end

    def new
        @pay_grade = PayGrade.new
    end

    def create
        @pay_grade = PayGrade.new(pay_grade_params)
        if @pay_grade.save
            redirect_to @pay_grade, notice: "Successfully added pay grade."
        else
             render action: 'new'
        end
    end

    def edit
    end

    def update
        if @pay_grade.update_attributes(pay_grade_params)
            redirect_to @pay_grade, notice: "Updated pay grade information."
          else
            render action: 'edit'
          end
    end

    private
    def set_pay_grades
        @pay_grade = PayGrade.find(params[:id])
      end

    def pay_grade_params
        params.require(:pay_grade).permit(:level, :active)
    end

end