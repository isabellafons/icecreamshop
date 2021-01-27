# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(employee)
       employee ||= Employee.new # guest user (not logged in)
       if employee.role? :admin
         can :manage, :all
         

       elsif employee.role? :employee

        can :shift_button_in, :all
        can :shift_button_out, :all
        can :show_week_pay, :all
        # they can read their own profile
          can :show, Employee do |u|  
            u.id == employee.id
          end
      
        # they can update their own profile
        can :update, Employee do |u|  
          u.id == employee.id
        end

        can :index, Assignment
        can :index, Shift
        
        can :show, Assignment do |this_assign|  
          my_assigns = employee.assignments.map(&:id)
          my_assigns.include? this_assign.id 
        end

        can :show, Shift do |this_shift|  
          my_shifts = employee.shifts.map(&:id)
          my_shifts.include? this_shift.id 
        end
       
        elsif employee.role? :manager
          can :manage, Shift
          can :manage, ShiftJob
          can :index, Job
          can :show, Job
          can :index, Store
          can :index, Employee
          can :index, Assignment

          can :shift_button_in, :all
        can :shift_button_out, :all
        can :show_week_pay, :all

          can :show, Store do |this_store|  
            my_stores = employee.stores.map(&:id)
            my_stores.include? this_store.id 
          end

          #can show employees/assignments at their own store
          can :show, Assignment do |this_assign|
            my_assign = employee.current_assignment.store.assignments.map(&:id)
            my_assign.include? this_assign.id
          end

          can :show, Employee do |this_employ|
            my_employ = employee.current_assignment.store.employees.map(&:id)
            my_employ.include? this_employ.id
          end

          can :edit, Employee do |this_employ|
            my_employ = employee.current_assignment.store.employees.map(&:id)
            my_employ.include? this_employ.id
          end

          can :update, Employee do |this_employ|
            my_employ = employee.current_assignment.store.employees.map(&:id)
            my_employ.include? this_employ.id
          end

       
      else
      end
    
  end
end
