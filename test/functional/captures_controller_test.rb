require 'test_helper'

class CapturesControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, {'id' => "66d79a7f-2e5c-42e4-9ece-8b2cafe91416"}
    assert_select "div#hints>h2:first-of-type", "Capture Details"
    assert_select 'div[title="This is the URL of the image displayed"]',"Source URL: http://www.ibm.com"
    assert_select 'div[title="This is the date and time of the retrieval"]',"Source URL Retrieval Date: 2011-07-20 22:05:24 UTC"

    assert_select 'div[title="73d93c11f68f8577c68babf10237bb1e2e0475aefe351fd3766e52de2af03e76 . This is the SHA256 has of the full page PNG.  You can verify that the image has not been tampered by using a tool like http://hash.online-convert.com/sha256-generator"]'

    assert_response :success
  end

  test "should get new" do
    get :new, {'url' => "http://www.google.com"}
    assert_select 'input#top'
    assert_select 'input#left'
    assert_select 'input#height'
    assert_select 'input#width'

    assert_select 'input#btnSubmit'

    assert_select 'div[id="screenpic_wrap"][style="width: 1030; height: 868px; "]'
    assert_select 'img[src="http://s3.amazonaws.com/vericap-dev/66d79a7f-2e5c-42e4-9ece-8b2cafe91416.png"][width="1030"][height="868"]'

    assert_response :success
  end

  test "should get new invalid url" do
    get :new, {'url' => "ht:p:/www.google..com"}
    assert_equal "http://ht:p:/www.google..com is not a valid address.  Please try again.", flash[:notice]
    assert_response :redirect
  end


  test "should put update invalid session" do
    put :update
    assert_equal CapturesController::RELAY_ATTACK_MESSAGE, flash[:notice]
    assert_response :redirect

  end


end
