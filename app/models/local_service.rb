require 'csv'

class LocalService
  include Mongoid::Document

  field :lgsl_code, type: String
  field :providing_tier, type: Array

  validates_presence_of :lgsl_code, :providing_tier
  validates_uniqueness_of :lgsl_code
  validates :providing_tier, :inclusion => { :in => [%w{county unitary}, %w{district unitary}, %w{district unitary county}] }
  
  def preferred_url(snac_list)
    providers = LocalAuthority.for_snacs(snac_list)
    provider = select_tier(providers)
    if provider
      urls = provider.local_service_urls.all_in(lgsl_code: lgsl_code)
      local_service_url = choose_preferred_url_from(urls)
      local_service_url && local_service_url.url
    end
  end
  
  def provided_by
    LocalAuthority.where('local_service_urls.lgsl_code' => lgsl_code).any_in(tier: providing_tier)
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
  
  def choose_preferred_url_from(urls)
    urls.not_in(lgil_code: LocalServiceUrl::LGIL_CODE_PROVIDING_INFORMATION).first ||
      urls.all_in(lgil_code: LocalServiceUrl::LGIL_CODE_PROVIDING_INFORMATION).first
  end
end
