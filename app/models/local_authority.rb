require 'csv'

class LocalAuthority
  include Mongoid::Document

  embeds_many :local_interactions
  
  field :name, type: String
  field :snac, type: String
  field :local_directgov_id, type: String
  field :tier, type: String
  
  scope :for_snacs, ->(snacs) { any_in(snac: snacs) }
  
  def find_by_snac(snac)
    for_snacs([snac]).first
  end
  
  def interactions_for(lgsl_code)
    local_interactions.all_in(lgsl_code: lgsl_code)
  end
  
  validates_uniqueness_of :snac, :local_directgov_id
  validates_presence_of :snac, :local_directgov_id, :name, :tier
end
