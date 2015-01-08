require 'test_helper'

class HelloControllerTest < ActionController::TestCase

  test "should get show" do
    get :show
    assert_response :success
    # puts @response.body
    assert_match /<h1>Hi there<\/h1>/, @response.body
    assert_match /link rel="stylesheet" media="all" href="\/assets\/application.css" data-turbolinks-track="true" \/>/, @response.body
    assert_no_match %Q(Dummy ShowDummy Show), @response.body
  end

end
