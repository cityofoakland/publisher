require 'test_helper'

class LocalTransactionTest < ActiveSupport::TestCase
  def lgsl
    @lgsl ||= LocalTransactionsSource::Lgsl.create(code: "1")
  end

  def create_authority(snac = "00BC")
    @authority ||= lgsl.authorities.create(snac: snac)
  end
  alias_method :authority, :create_authority

  context "a local transaction for the 'bins' service" do
    setup do
      @lgsl_code = 'bins'
      @bins_transaction = LocalTransaction.new(lgsl_code: @lgsl_code, name: "Transaction", slug: "slug")
    end
    
    context "an authority exists providing 'bins' service" do
      setup do
        @county_council = LocalAuthority.create(
          name: "Some County Council", 
          snac: '00AA', 
          local_directgov_id: 1, 
          tier: 'county',
          homepage_url: 'http://some.county.council.gov/',
          contact_url: 'http://some.county.council.gov/contact.html'
        )
        @county_council.local_service_urls.create!(
          url: 'http://some.county.council.gov/do.html',
          lgsl_code: @lgsl_code,
          lgil_code: 0)
      end
    
      should "report that that authority provides the bins service" do
        assert @bins_transaction.service_provided_by?(@county_council.snac)
      end

      should "report that some other authority does not provide the bins service" do
        assert ! @bins_transaction.service_provided_by?('some_other_snac')
      end
    end

    should "report the search_format to be 'transaction'" do
      assert_equal "transaction", @bins_transaction.search_format
    end
  end
  
  should_eventually "On save, validate that a LocalService exists for that lgsl_code"
end
