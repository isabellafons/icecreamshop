Rails.application.routes.draw do

  # Semi-static page routes
  get 'home', to: 'home#index', as: :home
  get 'home/about', to: 'home#about', as: :about
  get 'home/contact', to: 'home#contact', as: :contact
  get 'home/privacy', to: 'home#privacy', as: :privacy
  get 'home/error', to: 'home#error', as: :error
  get 'home/logged_in_home', to: 'home#logged_in_home', as: :logged_in_home

  post 'shift_button_in/:id', to: 'shifts#shift_button_in', as: :shift_button_in
  post 'shift_button_out/:id', to: 'shifts#shift_button_out', as: :shift_button_out


  # Resource routes (maps HTTP verbs to controller actions automatically):
  resources :employees
  resources :stores
  resources :assignments
  resources :shifts
  resources :jobs
  resources :pay_grades
  resources :pay_grade_rates
  resources :shift_jobs

  #Validation Routes CHECK
  # Authentication routes
  resources :sessions
  get 'employees/new', to: 'employees#new', as: :signup
  get 'employees/edit', to: 'employees#edit', as: :edit_current_user
  get 'login', to: 'sessions#new', as: :login
  get 'logout', to: 'sessions#destroy', as: :logout

  # Custom routes
  get 'home/search', to: 'home#search', as: :search

  patch 'assignments/:id/terminate', to: 'assignments#terminate', as: :terminate_assignment
  
  get 'store/payroll_generate/:id', to:'stores#payroll_generate', as: :payroll_generate
  post 'new_payroll_calc_form/:id', to:'stores#new_payroll_calc_form', as: :new_payroll_calc_form

  get 'store/show_payroll/:id', to:'stores#show_payroll', as: :show_payroll
  post 'payroll_nums/:id', to:'stores#payroll_nums', as: :payroll_nums

  post 'show_week_pay/:id', to: 'employees#show_week_pay', as: :show_week_pay
  get 'employee/show_pay/:id', to: 'employees#show_pay', as: :show_pay

  

  
  

  # You can have the root of your site routed with 'root'
  root 'home#index'
end
