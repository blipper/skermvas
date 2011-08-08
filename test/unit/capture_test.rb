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

  test "Capture full page www.google.com capture" do
    capture = Capture.new()
    capture.url = "http://www.google.com"
    capture.capturepage
    puts capture.inspect
    assert capture.save, "www.google.com full page capture failed"
    # Google SHA will change so just compare lengths
    assert capture.sha2.length == "73d93c11f68f8577c68babf10237bb1e2e0475aefe351fd3766e52de2af03e76".length, "No SHA2 signature found"
    assert_not_nil capture.retrievaldatetime, "No retrievaldatetime stamp found"
  end

  test "Capture full page www.google.com capture and crop" do
    capture = Capture.new()
    capture.url = "http://www.google.com"
    capture.capturepage
    capture.makeshorturls('http://www.skermvas.com' + '/test' + '/' + capture.uuid)
    capture.crop(100.to_s,100.to_s,10.to_s,10.to_s)
    capture.save
    puts capture.inspect
  end




end
