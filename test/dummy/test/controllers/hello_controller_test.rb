require 'test_helper'

class HelloControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
    assert_match /Hi there/, @response.body
  end

end
