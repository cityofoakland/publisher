require 'test_helper'
require 'local_transactions_importer'

class LocalTransactionsImporterTest < ActiveSupport::TestCase
  def sample_csv
    StringIO.new <<-eos
Authority Name,SNAC,LAid,Service Name,LGSL,LGIL,Service URL
London Borough of Hackney,00AM,139,Find out about hazardous waste collection,850,8,http://www.hackney.gov.uk/ew-hazerdouswastecollection-850.htm
London Borough of Hackney,00AM,139,Find out which day the refuse is collected ,524,8,http://www.hackney.gov.uk/ew-household-waste-collection-524.htm
eos
  end

  setup do
    @importer = LocalTransactionsImporter.new(sample_csv)
  end

  test "it creates an authority with correct details" do
    @importer.run
    new_authority = Authority.where(snac: '00AM').first
    assert new_authority
    assert_equal 'London Borough of Hackney', new_authority.name
  end

  test "it doesn't recreate an existing authority" do
    @importer.expects(:ensure_authority).once
    @importer.run
  end

  test "it creates an LGSL record" do
    @importer.run
    lts = LocalTransactionsSource.find_current_lgsl(524)
    assert lts
  end
end