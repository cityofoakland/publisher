require 'test_helper'

class UberEditionTest < ActiveSupport::TestCase
  test "it requires parts have titles and slugs when there are multiple parts" do
    u = UberEdition.new
    u.uber_parts.build(:title => "I have a title")
    u.uber_parts.build()
    assert ! u.valid?
    assert u.uber_parts.last.errors[:title].any?
    assert u.uber_parts.last.errors[:slug].any?
  end
  
  test "it doesn't require parts have titles or slugs when there is only one parts" do
    u = UberEdition.new
    u.uber_parts.build()
    assert u.valid?
  end
end