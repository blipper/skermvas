require 'securerandom'
require 'digest/sha2'
require 'RMagick'
require 'net/http'

include Magick

#noinspection ALL
class CapturesController < ApplicationController
  def generatefilename(uuid)
    "/tmp/" + uuid + ".png"
  end

  def generatecroppedfilename(uuid)
    "/tmp/" + uuid + "_cropped.png"
  end

  def generatecroppedimage(uuid, imagefilename)
    img = ImageList.new(imagefilename)

    puts params[:left] + "," + Integer(params[:top]).inspect
    puts params[:width] + "," + params[:height]
    crop = img.crop(Integer(params[:left]),Integer(params[:top]),Integer(params[:width]), Integer(params[:height]))
    crop.write(generatecroppedfilename(uuid))
    generatecroppedfilename(uuid)
  end

  def annotateimage(imagefilename,texttoadd)
    img = ImageList.new(imagefilename)
    draw = Draw.new

    draw.annotate(img, 0, 0, 0, 0, texttoadd) {self.gravity = Magick::SouthEastGravity}

=begin
    {
                                                  self.gravity = Magick::SouthGravity
                                                  self.pointsize = 48
                                                  self.fill = '#0000A9'
                                                  self.font_weight = Magick::BoldWeight
                                                  }
=end
    img.write(imagefilename)
  end


  def capturepagetoimage(url, imagefilename)
    cmdlineurl = Shellwords.escape(url)

    `#{Rails.root}/lib/saveimage/SaveImage #{cmdlineurl} #{imagefilename}`
  end

  ACCESS_KEY_ID = 'AKIAJH26DM2XHHIUJ5LQ'
  SECRET_ACCESS_KEY = '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'
  OURBUCKET = 'vericap-dev'
  USERNAME = 'blipper2000'
  PASSWORD = 'R_d9ddd569836fe5f60f98cf0a9f35d85f'

  def generateAWSurl(keyname)
    'http://s3.amazonaws.com/'+OURBUCKET+'/'+keyname+'.png'
  end

  def pushtoaws(keyname,localimagefilename)
    s3 = RightAws::S3.new(ACCESS_KEY_ID, SECRET_ACCESS_KEY)
    bucket = s3.bucket(OURBUCKET)
    puts bucket.inspect
    bucket.put(keyname+'.png',File.open(localimagefilename),{},'public-read')
   return generateAWSurl(keyname)
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
    @fullimageurl = generateAWSurl(@capture.uuid)
    @croppedimageurl = generateAWSurl(@capture.uuid+'_cropped')

    if params.key?(:cropped)
      redirect_to generateAWSurl(@capture.uuid+"_cropped")
    end
    puts @capture
  end

  def new
    @capture = Capture.new
    @capture.uuid = SecureRandom.uuid
    @capture.url = params[:url]
    if @capture.valid?
      puts "URL validated!"
    else
      flash[:notice] = "Invalid URL"
      redirect_to(root_url)
    end


    localimagefilename = generatefilename(@capture.uuid)

    capturepagetoimage(@capture.url, localimagefilename)
    @fullimageurl = pushtoaws(@capture.uuid,localimagefilename)
    puts @fullimageurl

    @capture.retrievaldate = Time.new
    @capture.sha2 = Digest::SHA2.file(localimagefilename).hexdigest
    @capture.save
    File.delete(localimagefilename)
    session[:capture] = @capture
    puts session[:capture].inspect
  end

  def update
    @capture = session[:capture]
    puts @capture.inspect
    authorize = UrlShortener::Authorize.new USERNAME, PASSWORD
    client = UrlShortener::Client.new(authorize)
    shorten = client.shorten('http://www.vericap.com/'+ captures_path + '?uuid=' + @capture.uuid) # => UrlShortener::Response::Shorten object
    @capture.shorturl = shorten.urls

    localimagefilename = generatefilename(@capture.uuid)
    pullfromaws(@capture.uuid,localimagefilename)
    generatecroppedimage(@capture.uuid,localimagefilename)
    annotateimage(generatecroppedfilename(@capture.uuid),"VeriCap - Verify at " + @capture.shorturl)
    @croppedimageurl = pushtoaws(@capture.uuid+'_cropped',generatecroppedfilename(@capture.uuid))
    @capture.save
    puts @capture.errors.inspect
    redirect_to @capture
  end

end
