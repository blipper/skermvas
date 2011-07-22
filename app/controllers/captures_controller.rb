class CapturesController < ApplicationController



  def show
    @capture = Capture.find(params[:id])

    if params.key?(:cropped)
      redirect_to generate_aws_url(@capture.uuid+"_cropped")
    end
    logger.debug @capture.inspect
  end

  def new
    @capture = Capture.new
    @capture.url = params[:url]
    @capture.cookiejar = params[:cookiejar]

    # Test the URL for correctness
    @capture.valid?
    logger.info @capture.errors.inspect
    if @capture.errors[:url].any?
      flash[:notice] = @capture.url + ' is not a valid address.  Please try again.'
      redirect_to(root_url)
      return
    end
    @capture.errors.clear

    @capture.capturepage

    if @capture.save
      session[:capture] = @capture
      logger.debug session[:capture].inspect
    else
      raise 'Problem saving a capture ' + @capture.errors.inspect
    end
  end

  RELAY_ATTACK_MESSAGE = 'It is not permitted to try to capture the same image again.  Please reload the site you wish to capture.'

  def create
    # Handle Extension Create Case
    new
  end

  def update
    @capture = session[:capture]
    # Check for replay attack
    if session[:capture]==nil || (@capture.shorturl!=nil)
      flash[:notice] = RELAY_ATTACK_MESSAGE
      redirect_to(root_url)
      return
    end
    @capture.makeshorturls('http://www.skermvas.com'+ captures_path + '/' + @capture.uuid)
    @capture.crop(params[:width],params[:height],params[:left],params[:top])
    @capture.save

    # Clear the capture object so that replay
    session[:capture] = nil
    logger.debug @capture.errors.inspect
    redirect_to @capture
  end
end
