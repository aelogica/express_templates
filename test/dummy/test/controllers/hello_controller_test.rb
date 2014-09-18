require 'test_helper'

class HelloControllerTest < ActionController::TestCase

  test "view context class should be Gara::Context" do
    assert HelloController.new.view_context.class == Gara::Context
  end

  test "should get show" do
    get :show
    assert_response :success
    # puts @response.body
    assert_match /<h1>Hi there<\/h1>/, @response.body
    assert_match %Q(<link data-turbolinks-track="true" href="/assets/application.css" media="all" rel="stylesheet" />), @response.body
    assert_no_match %Q(Dummy ShowDummy Show), @response.body
  end

end
