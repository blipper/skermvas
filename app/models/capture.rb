class Capture < ActiveRecord::Base
  include ActiveModel::Validations
  #attr_accessor :url DO NOT NEED THIS FOR RAILS SINCE IT ALREADY CREATES THE ACCESSOR
  validates_url :url, :allow_blank => false
  set_primary_key :uuid
end
