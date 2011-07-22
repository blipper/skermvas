require 'securerandom'
require 'digest/sha2'
require 'net/http'


class Capture < ActiveRecord::Base
  include ActiveModel::Validations
  #attr_accessor :url DO NOT NEED THIS FOR RAILS SINCE IT ALREADY CREATES THE ACCESSOR
  validates_url :url, :allow_blank => false
  validates :sha2, :presence => true
  validates :uuid, :presence => true
  validates :retrievaldatetime,:presence =>true
  set_primary_key :uuid

  after_initialize do
    if uuid==nil
      self.uuid = SecureRandom.uuid
    end
  end


  def capturepage
    localimagefilename = generatefilename(uuid)
    capturepagetoimage(url, localimagefilename,uuid)
    calcdimensions(self,localimagefilename)
    logger.debug self.inspect

    pushtoaws(uuid,localimagefilename)

    self.retrievaldatetime = Time.new
    self.sha2 = Digest::SHA2.file(localimagefilename).hexdigest
    File.delete(localimagefilename)
  end

  def crop(width,height,left,top)
    localimagefilename = generatefilename(self.uuid)
    pullfromaws(self.uuid,localimagefilename)
    croppedimagefilename = generatecroppedimage(self.uuid,localimagefilename,width,height,left,top)
    annotateimage(croppedimagefilename,"Skermvas - Verify at " + self.shorturl)
    @croppedimageurl = pushtoaws(self.uuid+'_cropped',croppedimagefilename)
  end

  def makeshorturls(url)
    authorize = UrlShortener::Authorize.new USERNAME, PASSWORD
    client = UrlShortener::Client.new(authorize)
    self.shorturl = client.shorten(url).urls # => UrlShortener::Response::Shorten object
    self.croppedshorturl = client.shorten(url+ '?cropped=1').urls # => UrlShortener::Response::Shorten object
  end

  def fullimageurl
    generate_aws_url(uuid)
  end

  def croppedimageurl
    generate_aws_url(uuid+'_cropped')
  end



  private
  ACCESS_KEY_ID = 'AKIAJH26DM2XHHIUJ5LQ'
  SECRET_ACCESS_KEY = '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'
  OURBUCKET = 'vericap-dev'
  USERNAME = 'blipper2000'
  PASSWORD = 'R_d9ddd569836fe5f60f98cf0a9f35d85f'
  EC2AWESOMNIUMBOX = 'ec2-184-72-92-153.compute-1.amazonaws.com'

  def generatefilename(uuid)
    Dir.tmpdir.to_s + "/" + uuid + ".png"
  end

  def generatecroppedfilename(uuid)
    Dir.tmpdir.to_s + "/" + uuid + "_cropped.png"
  end

  def generatecroppedimage(uuid, imagefilename,width,height,left,top)
    #ENV['MAGICK_THREAD_LIMIT']='1'
    #logger.debug ENV['MAGICK_THREAD_LIMIT']
    #TODO Fix this dirty exec hack that works around bug in Heroku RMAgick library
    # Use systemt to avoid command line injection
    # See man page for
    if !system('convert',imagefilename,'-crop',width+'x'+height+'+'+left+'+'+top,generatecroppedfilename(uuid))
      raise "Could not convert imagefile"
    end
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


end
