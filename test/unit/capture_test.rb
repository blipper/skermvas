require 'test_helper'

class CaptureTest < ActiveSupport::TestCase

  test "Make sure you can't save empty capture" do
    capture = Capture.new()
    capture.url = "www.google.com"
    assert !capture.save, "Saved empty capture!!"
  end

  test "Successfully save complete capture" do
    capture = captures(:complete)
    assert capture.save, "Complete capture not saved!"
  end

  test "Make sure capture missing UUID can't be saved" do
    capture = captures(:complete)
    capture.uuid = nil
    assert !capture.save, "Capture with nil uuid saved!"
  end

  test "Make sure capture missing url can't be saved" do
    capture = captures(:complete)
    capture.url = nil
    assert !capture.save, "Capture with nil url saved!"
  end

  test "Make sure capture with invalid URL cannot be saved" do
    capture = captures(:complete)
    capture.url = 'htt:/fas..fd'
    assert !capture.save, "Capture with invalid url saved!"
  end


  test "test full image URL" do
    capture = Capture.new()
    capture.url = "www.google.com"
    capture.fullimageurl
    assert !capture.save, "Saved empty capture!!"
  end


end
