class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # handle 404 errors with an exception as well
 rescue_from ActiveRecord::RecordNotFound do |exception|

    # consider creating your own 404 page within home and redirecting there...
    
   flash[:error] = "error! not found...... "
   redirect_to error_path
  end


  private
  # Handling authentication
  def current_user
    @current_user ||= Employee.find(session[:employee_id]) if session[:employee_id]
  end
  helper_method :current_user
  
  def logged_in?
    current_user
  end
  helper_method :logged_in?
  
  def check_login
    redirect_to login_path, alert: "You need to log in to view this page." if current_user.nil?
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access Denied! You are unauthorized to view this page."
    redirect_to home_path
  end
  
end
