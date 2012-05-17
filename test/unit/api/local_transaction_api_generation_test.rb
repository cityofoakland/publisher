require 'test_helper'
require 'govuk_content_models/test_helpers/local_services'

class LocalTransactionApiGenerationTest < ActiveSupport::TestCase
  include LocalServicesHelper

  def set_up_interaction(authority_label)
    @county_council = FactoryGirl.create(authority_label)
    @interaction = FactoryGirl.create(:local_interaction, local_authority: @county_council)
  end

  def set_up_edition(interaction = nil)
    if interaction.nil?
      service = FactoryGirl.create(:local_service)
    else
      service = FactoryGirl.create(:local_service, lgsl_code: interaction.lgsl_code)
    end
    FactoryGirl.create(:local_transaction_edition,
                          lgsl_code: service.lgsl_code,
                          title: "Test local transaction",
                          slug: "test_slug"
    )
  end

  def set_up_edition_with_interaction(authority_label)
    set_up_interaction(authority_label)
    @edition = set_up_edition(@interaction)
  end

  setup do
    set_up_edition_with_interaction(:local_authority_with_contact)
  end

  def only_keys(hash, keys)
    hash.select {|k,v| [*keys].include?(k)}
  end

  context "no snac specified" do
    setup { @generated = Api::Generator::edition_to_hash(@edition) }

    should "generate hash with title and slug" do
      expected_hash = {
        'title' => "Test local transaction",
        'slug' => "test_slug"
      }

      assert_equal expected_hash, only_keys(@generated, %w{title slug})
    end
  end

  context "snac specified" do
    setup do
      @generated = Api::Generator::edition_to_hash(@edition, :snac => @county_council.snac)
    end

    should "also include description of service interaction and authority" do
      assert @generated.has_key?('interaction')


      expected_authority = {
        'name'    => @county_council.name,
        'snac'    => @county_council.snac,
        'tier'    => @county_council.tier,
        'contact_address' => @county_council.contact_address,
        'contact_url'     => @county_council.contact_url,
        'contact_phone'   => @county_council.contact_phone,
        'contact_email'   => @county_council.contact_email
      }
      expected_interaction_description = {
        'url' => "http://some.council.gov/do.html",
        'lgil_code' => 0,
        'lgsl_code' => @interaction.lgsl_code,
        'authority' => expected_authority
      }

      assert_equal expected_interaction_description, @generated['interaction']
      assert_equal expected_authority, @generated['authority']
    end

    should "include description of service interaction and authority even if no contact information is available" do[]
      set_up_edition_with_interaction(:local_authority)
      @generated = Api::Generator::edition_to_hash(@edition, :snac => @county_council.snac)
      expected_authority = {
        'name'    => @county_council.name,
        'snac'    => @county_council.snac,
        'tier'    => @county_council.tier,
        'contact_address' => nil,
        'contact_url'     => nil,
        'contact_phone'   => nil,
        'contact_email'   => nil
      }
      expected_interaction_description = {
        'url' => "http://some.council.gov/do.html",
        'lgil_code' => 0,
        'lgsl_code' => @interaction.lgsl_code,
        'authority' => expected_authority
      }
      assert_equal expected_interaction_description, @generated['interaction']
      assert_equal expected_authority, @generated['authority']
    end
  end

  context "snac exists but doesn't have that interaction" do
    setup do
      @edition2 = set_up_edition
    end

    should "an empty interaction" do
      generated = Api::Generator::edition_to_hash(@edition2, :snac => @county_council.snac)

      expected_authority = {
        'name'    => @county_council.name,
        'snac'    => @county_council.snac,
        'tier'    => @county_council.tier,
        'contact_address' => @county_council.contact_address,
        'contact_url'     => @county_council.contact_url,
        'contact_phone'   => @county_council.contact_phone,
        'contact_email'   => @county_council.contact_email
      }

      assert_equal nil, generated['interaction']
      assert_equal expected_authority, generated['authority']
    end
  end

  context "all interactions requested" do
    setup do
      @council2 = FactoryGirl.create(:local_authority, snac: 'BB00')
      FactoryGirl.create(:local_authority, snac: 'CC00')
      @generated = Api::Generator::edition_to_hash(@edition, :all => true)
    end

    should_eventually "also include description of service interaction and authority" do
      # We suspect that this feature is not currently used anywhere, and not exposed
      # through the public api.
      assert @generated.has_key?('interactions')

      interactions = []
      interactions << {
        'url' => "http://some.county.council.gov/do-#{@lgsl_code}.html",
        'lgil_code' => "0",
        'lgsl_code' => @lgsl_code,
        'authority' => {
          'name' => @county_council.name,
          'snac' => @county_council.snac,
          'tier' => @county_council.tier
        }
      }

      interactions << {
        'url' => "http://some.county.council.gov/do-#{@lgsl_code}.html",
        'lgil_code' => "0",
        'lgsl_code' => @lgsl_code,
        'authority' => {
          'name' => @council2.name,
          'snac' => @council2.snac,
          'tier' => @council2.tier
        }
      }

      assert_equal interactions, @generated['interactions']
    end
  end
end
