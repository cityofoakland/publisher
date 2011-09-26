require 'test_helper'
require 'capybara/rails'

Capybara.default_driver = :selenium
Capybara.server_port = 4000
Capybara.app = Rack::Builder.new do
  map "/" do
    run Capybara.app
  end
end

class AddingPartsToGuidesTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def teardown
    DatabaseCleaner.clean
  end

  test "Publishing a guide" do
     without_panopticon_validation do

       # This isn't right, really need a way to run actions when
     # logged in as particular users without having Signonotron running.
     #
     User.create(:uid=>"ADADS",:name=>"T Est",:email=>"test@example.com")

     random_name = (0...8).map{65.+(rand(25)).chr}.join + " GUIDE"

     guide = Guide.new :name => random_name, :slug => 'test-guide', :panopticon_id => 2356
     guide.save!

     stub_request(:get, "http://panopticon.test.gov.uk/artefacts/2356.js").
       to_return(:status => 200, :body => "{}", :headers => {})

     visit    "/admin/guides/#{guide.to_param}"

     click_on 'Untitled part'
     within :css, '#parts div.part:first-of-type' do
       fill_in 'Title' , :with => 'Part One'
       fill_in 'Body', :with => 'Body text'
       fill_in 'Slug', :with => 'part-one'
     end
     click_on 'Add new part'
     within :css, '#parts div.part:nth-of-type(2)' do
       fill_in 'Title' , :with => 'Part Two'
       fill_in 'Body', :with => 'Body text'
       fill_in 'Slug', :with => 'part-two'
     end
     within(:css, '#guide-controls') { click_on 'Save' }

     click_on 'Add new part'
     within :css, '#parts div.part:nth-of-type(3)' do
       fill_in 'Title' , :with => 'Part Three'
       fill_in 'Body', :with => 'Body text'
       fill_in 'Slug', :with => 'part-three'
     end
     within(:css, '#guide-controls') { click_on 'Save' }

     assert_equal 3, all(:css, '#parts > div.part').length

     visit "/admin"

     within(:css, '#new') {
        assert page.has_content? random_name
     }

     end
   end
end
