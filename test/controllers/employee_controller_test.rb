require 'test_helper'

class EmployeeControllerTest < ActionDispatch::IntegrationTest

  
  test "should get search" do
    get search_path, params: { query: "Me" }
    assert_response :success
  end
  
  test "should handle blank search" do
    get search_path, params: { query: nil }
    assert_response :redirect
  end

end
