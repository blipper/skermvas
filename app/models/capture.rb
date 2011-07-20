class Capture < ActiveRecord::Base
  include ActiveModel::Validations
  #attr_accessor :url DO NOT NEED THIS FOR RAILS SINCE IT ALREADY CREATES THE ACCESSOR
  validates_url :url, :allow_blank => false
  validates :sha2, :presence => true
  validates :uuid, :presence => true
  validates :retrievaldatetime,:presence =>true
  set_primary_key :uuid
end
