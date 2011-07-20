require 'securerandom'
require 'digest/sha2'
require 'net/http'

class CapturesController < ApplicationController
  def generatefilename(uuid)
    Dir.tmpdir.to_s + "/" + uuid + ".png"
  end

  def generatecroppedfilename(uuid)
    Dir.tmpdir.to_s + "/" + uuid + "_cropped.png"
  end

  def generatecroppedimage(uuid, imagefilename)
    #img = Magick::ImageList.new(imagefilename)

    logger.debug params[:left] + "," + Integer(params[:top]).inspect
    logger.debug params[:width] + "," + params[:height]
    #ENV['MAGICK_THREAD_LIMIT']='1'
    #logger.debug ENV['MAGICK_THREAD_LIMIT']
    #TODO Fix this dirty exec hack that works around bug in Heroku RMAgick library
    #crop = img.crop(Integer(params[:left]),Integer(params[:top]),Integer(params[:width]), Integer(params[:height]))
    # Use systemt to avoid command line injection
    # See man page for
    if !system('convert',imagefilename,'-crop',params[:width]+'x'+params[:height]+'+'+params[:left]+'+'+params[:top],generatecroppedfilename(uuid))
      raise "Could not convert imagefile"
    end
    #Like this `convert #{imagefilename} -crop #{params[:width]}x+10+10 #{generatecroppedfilename(uuid)}`
    #crop.write(generatecroppedfilename(uuid))
    generatecroppedfilename(uuid)
  end

  def annotateimage(imagefilename,texttoadd)
    #TODO Fix .png assumption hack
    renamedimagefilename = Dir.tmpdir.to_s + '/' + File.basename(imagefilename,".png") + "_old.png"
    logger.debug renamedimagefilename
    if !FileUtils.mv(imagefilename, renamedimagefilename)
      raise "Could not rename " + imagefilename + ' to ' + renamedimagefilename
    end
    logger.info 'Starting Convert'
    logger.info texttoadd
    if !system('convert',renamedimagefilename,'-background', 'Khaki', '-gravity','Center',"label:'"+texttoadd+"'",'-append',imagefilename)
      raise "Could not annotate imagefile"
    end
    logger.info 'Ending Convert'


    #img = Magick::ImageList.new(renamedimagefilename)
    #draw = Magick::Draw.new
    #draw.annotate(img, 0, 0, 0, 0, 'ARGH')  {
    #self.gravity = Magick::SouthGravity
    #self.pointsize = 48
    #self.stroke = 'transparent'
    #self.fill = '#0000A9'
    #self.font_weight = Magick::BoldWeight
    #}

    #{self.gravity = Magick::SouthGravity
    #                                           self.pointsize = 6
    #                                           self.fill = '#0000A9'
    #}
=begin
    {
                                                  self.gravity = Magick::SouthGravity
                                                  self.pointsize = 48
                                                  self.fill = '#0000A9'
                                                  self.font_weight = Magick::BoldWeight
                                                  }
=end
    #img.write(imagefilename)
    FileUtils.rm(renamedimagefilename)
  end


  def capturepagetoimage(url, imagefilename,uuid)
    cmdlineurl = Shellwords.escape(url)
    logger.debug Rails.env
      #TODO Dirty hack until we get Awesomenium running on Heroku
      Net::HTTP.start(EC2AWESOMNIUMBOX,3000) { |http|
        resp = http.get('/sis.json?uuid='+uuid+'&'+'url='+url)
        mysi = JSON.parse(resp.body)
        logger.info mysi.inspect
        pullfromaws(uuid,imagefilename)
      }
    #End Dirty Hack
  end

  def calcdimensions(imgcap,imagefilename)
    img = Magick::ImageList.new(imagefilename)
    imgcap.pngwidth = img.columns
    imgcap.pngheight = img.rows
  end

  ACCESS_KEY_ID = 'AKIAJH26DM2XHHIUJ5LQ'
  SECRET_ACCESS_KEY = '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'
  OURBUCKET = 'vericap-dev'
  USERNAME = 'blipper2000'
  PASSWORD = 'R_d9ddd569836fe5f60f98cf0a9f35d85f'
  EC2AWESOMNIUMBOX = 'ec2-184-72-92-153.compute-1.amazonaws.com'

  def generate_aws_url(keyname)
    'http://s3.amazonaws.com/'+OURBUCKET+'/'+keyname+'.png'
  end

  def pushtoaws(keyname,localimagefilename)
    s3 = RightAws::S3.new(ACCESS_KEY_ID, SECRET_ACCESS_KEY)
    bucket = s3.bucket(OURBUCKET)
    logger.debug bucket.inspect
    bucket.put(keyname+'.png',File.open(localimagefilename),{},'public-read')
    generate_aws_url(keyname)
  end

  def pullfromaws(keyname,localimagefilename)
      ourbucket = 'vericap-dev'

      Net::HTTP.start('s3.amazonaws.com') { |http|
      resp = http.get('/'+ourbucket+'/'+keyname+".png")
      open(localimagefilename, 'wb') { |file|
        file.write(resp.body)
        }
      }
  end


  def show
    @capture = Capture.find(params[:id])
    @fullimageurl = generate_aws_url(@capture.uuid)
    @croppedimageurl = generate_aws_url(@capture.uuid+'_cropped')

    if params.key?(:cropped)
      redirect_to generate_aws_url(@capture.uuid+"_cropped")
    end
    logger.debug @capture.inspect
  end

  def new
    @capture = Capture.new
    @capture.uuid = SecureRandom.uuid
    @capture.url = params[:url]

    # Test the URL for correctness
    @capture.valid?
    logger.info @capture.errors.inspect
    if @capture.errors[:url].any?
      flash[:notice] = @capture.url + ' is not a valid address.  Please try again.'
      redirect_to(root_url)
      return
    end
    @capture.errors.clear

    localimagefilename = generatefilename(@capture.uuid)
    capturepagetoimage(@capture.url, localimagefilename,@capture.uuid)
    calcdimensions(@capture,localimagefilename)
    logger.debug @capture.inspect

    @fullimageurl = pushtoaws(@capture.uuid,localimagefilename)
    logger.debug @fullimageurl

    @capture.retrievaldatetime = Time.new
    @capture.sha2 = Digest::SHA2.file(localimagefilename).hexdigest
    File.delete(localimagefilename)

    if @capture.save
      session[:capture] = @capture
      logger.debug session[:capture].inspect
    else
      raise 'Problem saving a capture ' + @capture.errors.inspect
    end
  end

  def getshorturl
    authorize = UrlShortener::Authorize.new USERNAME, PASSWORD
    client = UrlShortener::Client.new(authorize)
    client.shorten('http://www.skermvas.com'+ captures_path + '/' + @capture.uuid) # => UrlShortener::Response::Shorten object
  end

  def update
    @capture = session[:capture]
    @capture.shorturl = getshorturl.urls

    localimagefilename = generatefilename(@capture.uuid)
    pullfromaws(@capture.uuid,localimagefilename)
    croppedimagefilename = generatecroppedimage(@capture.uuid,localimagefilename)
    annotateimage(croppedimagefilename,"Skermvas - Verify at " + @capture.shorturl)
    @croppedimageurl = pushtoaws(@capture.uuid+'_cropped',croppedimagefilename)
    @capture.save
    logger.debug @capture.errors.inspect
    redirect_to @capture
  end
end
