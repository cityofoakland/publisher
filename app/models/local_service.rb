require 'csv'

class LocalService
  include Mongoid::Document

  field :lgsl_code, type: String
  field :providing_tier, type: Array

  validates_presence_of :lgsl_code, :providing_tier
  validates_uniqueness_of :lgsl_code
  validates :providing_tier, :inclusion => { :in => [%w{county unitary}, %w{district unitary}, %w{district unitary county}] }
  
  def preferred_interaction(snac_list)
    provider = preferred_provider(snac_list)
    if provider
      available_interactions = provider.interactions_for(lgsl_code)
      choose_preferred_interaction_from(available_interactions)
    end
  end
  
  def preferred_provider(snac_list)
    snac_list = [*snac_list]
    providers = LocalAuthority.for_snacs(snac_list)
    select_tier(providers)
  end
  
  def provided_by
    LocalAuthority.where('local_interactions.lgsl_code' => lgsl_code).any_in(tier: providing_tier)
  end

  def select_tier(authorities)
    by_tier = Hash[authorities.map {|a| [a.tier, a]}]
    case providing_tier
    when %w{county unitary} then
      by_tier['county'] || by_tier['unitary']
    when %w{district unitary} then
      by_tier['district'] || by_tier['unitary']
    else
      by_tier['district'] || by_tier['unitary'] || by_tier['county']
    end
  end
  
  def choose_preferred_interaction_from(interactions)
    interactions.not_in(lgil_code: LocalInteraction::LGIL_CODE_PROVIDING_INFORMATION).first ||
      interactions.all_in(lgil_code: LocalInteraction::LGIL_CODE_PROVIDING_INFORMATION).first
  end
end
