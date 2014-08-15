require 'test_helper'

class HelloControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
    assert_match /Hi there/, @response.body
    assert_match %Q(<link data-turbolinks-track="true" href="/assets/application.css" media="all" rel="stylesheet" />), @response.body
  end

end
