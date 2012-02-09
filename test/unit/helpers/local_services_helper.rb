module LocalServicesHelper
  def make_authority(tier, options)
    @next_id ||= 1 
    @next_id += 1
    authority = LocalAuthority.create!(
      name: "Some #{tier.capitalize} Council", 
      snac: options[:snac], 
      local_directgov_id: @next_id, 
      tier: tier
    )
    add_service(authority, options[:lgsl])
    authority
  end
  
  def add_service(existing_authority, lgsl_code)
    existing_authority.local_interactions.create!(
      url: "http://some.#{existing_authority.tier}.council.gov/do-#{lgsl_code}.html",
      lgsl_code: lgsl_code,
      lgil_code: 0)
  end
end