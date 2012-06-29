require 'test_helper'

class SearchableTest < ActiveSupport::TestCase

  def template_guide_edition
    edition = GuideEdition.create(:title => 'Guide', :slug => 'guide', :panopticon_id => 1)
    edition.start_work
    edition
  end

  def create_part(order, name, body = "this is the content body")
    Part.new(order: order,
             title: "Title of the #{name} part",
             body: body,
             slug: "title-of-#{name}-part")
  end

  test "section name is normalized" do
    edition = template_guide_edition
    edition.section = "Cats and Dogs"
    assert_equal "cats-and-dogs", edition.search_index['section']
  end

  test "subsection field of search_index is populated by splitting section on colon" do
    edition = template_guide_edition
    edition.section = "Crime and Justice:Prison"
    assert_equal 'crime-and-justice', edition.search_index['section']
    assert_equal 'prison', edition.search_index['subsection']
  end

  test "should add the correct link order for edition parts" do
    edition = template_guide_edition
    edition.parts << create_part(2, "second")
    edition.parts << create_part(1, "first")

    edition.state = "published"
    edition.safely.save!

    document = edition.search_index

    assert_equal 2, document['additional_links'].length
    assert_equal 2, document['additional_links'][0]['link_order']
    assert_equal 1, document['additional_links'][1]['link_order']
  end

  test "should strip out govspeak when calling indexable_content_with_parts" do
    edition = template_guide_edition
    edition.parts << create_part(1, "first", "This is [link](http://example.net/) text.")
    edition.parts << create_part(2, "second", "This is some **version** text.")

    edition.state = "published"
    edition.safely.save!

    assert_equal "Title of the first part This is link text. Title of the second part This is some version text.", edition.indexable_content_with_parts
  end

  test "should strip out govspeak when asking for indexable content" do
    edition = template_guide_edition
    edition.parts << create_part(1, "first", "This is [link](http://example.net/) text.")
    edition.parts << create_part(2, "second", "This is some **version** text.")

    edition.state = "published"
    edition.safely.save!

    assert_equal "Title of the first part This is link text. Title of the second part This is some version text.", edition.indexable_content
  end
end
