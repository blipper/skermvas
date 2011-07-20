require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_select 'input[class="submit"]'
    assert_select 'input#url'
    assert_select 'div#Intro>h1'
  end

end
