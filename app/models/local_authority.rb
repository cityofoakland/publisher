require 'csv'

class LocalAuthority
  include Mongoid::Document

  embeds_many :local_interactions
  
  field :name, type: String
  field :snac, type: String
  field :local_directgov_id, type: String
  field :tier, type: String

  validates_uniqueness_of :snac, :local_directgov_id
  validates_presence_of :snac, :local_directgov_id, :name, :tier
  
  scope :for_snacs, ->(snacs) { any_in(snac: snacs) }
  
  def self.find_by_snac(snac)
    for_snacs([snac]).first
  end

  def provides_service?(lgsl_code)
    interactions_for(lgsl_code).any?
  end
  
  def interactions_for(lgsl_code)
    local_interactions.all_in(lgsl_code: lgsl_code)
  end
  
  def preferred_interaction_for(lgsl_code)
    interactions = interactions_for(lgsl_code)
    interactions.not_in(lgil_code: LocalInteraction::LGIL_CODE_PROVIDING_INFORMATION).first ||
      interactions.all_in(lgil_code: LocalInteraction::LGIL_CODE_PROVIDING_INFORMATION).first
  end
  
end
