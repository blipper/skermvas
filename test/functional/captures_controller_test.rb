require 'test_helper'

class CapturesControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, {'id' => "66d79a7f-2e5c-42e4-9ece-8b2cafe91416"}
    assert_select "div#hints>h2:first-of-type", "Capture Details"
    assert_select 'div[title="This is the URL of the image displayed"]',"Source URL: http://www.ibm.com"
    assert_select 'div[title="This is the date and time of the retrieval"]',"Source URL Retrieval Date: 2011-07-20 22:05:24 UTC"
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :redirect
  end

  test "should get create" do
    get :create
    assert_response :success
  end

end
