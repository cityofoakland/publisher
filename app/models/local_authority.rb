require 'csv'

class LocalAuthority
  include Mongoid::Document

  embeds_many :local_service_urls
  
  field :name, type: String
  field :snac, type: String
  field :local_directgov_id, type: String
  field :tier, type: String
  field :homepage_url, type: String
  field :contact_url, type: String
  
  scope :for_snacs, ->(snacs) { any_in(snac: snacs) }
  
  validates_uniqueness_of :snac, :local_directgov_id
  validates_presence_of :snac, :local_directgov_id, :name, :tier
end
