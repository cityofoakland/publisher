require 'test_helper'

class LocalTransactionApiGenerationTest < ActiveSupport::TestCase
  setup do
    @updated_time = Time.now
    @lgsl_code = '149'
    @snac_code = @snac_code
    @county_council = LocalAuthority.create(
      name: "Some County Council", 
      snac: @snac_code, 
      local_directgov_id: 1, 
      tier: 'county'
    )
    @county_council.local_service_urls.create!(
      url: 'http://some.county.council.gov/do.html',
      lgsl_code: @lgsl_code,
      lgil_code: 8)
    @local_transaction = LocalTransaction.new(slug: 'test_slug', tags: 'tag, other', :lgsl_code => @lgsl_code)
    @local_transaction.editions.first.attributes = {version_number: 1, title: 'Test local transaction', updated_at: @updated_time}
    @edition = @local_transaction.editions.first
  end

  def generated(*args)
    Api::Generator::edition_to_hash(@edition, *args)
  end

  test "generated hash has slug" do
    assert_equal "test_slug", generated['slug']
  end

  test "generated hash has the edition's title" do
    assert_equal "Test local transaction", generated['title']
  end

  test "generated hash has nothing about service provision" do
    assert !generated.has_key?('authority')
  end

  test "generated hash for result page has the authority" do
    assert generated(:snac => @snac_code).has_key?('authority')
  end

  test "generated hash for result page has the authorities' name" do
    assert "Authority", generated(:snac => @snac_code)['authority']['name']
  end

  test "generated hash for result page has the authorities' snac code" do
    assert @snac_code, generated(:snac => @snac_code)['authority']['snac']
  end

  test "generated hash for result page has an lgil code for the authority" do
    assert "8", generated(:snac => @snac_code)['authority']['lgils'].first['code']
  end

  test "generated hash for result page has an lgil url for the authority" do
    assert "http://authority.gov.uk/service", generated(:snac => @snac_code)['authority']['lgils'].first['url']
  end
end