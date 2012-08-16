require 'test_helper'

class ParamSanitizerTest < ActiveSupport::TestCase
  test "it removes HTML from multiple keys" do
    input = {
      first_key: '<p class="evil">Hello!</p>',
      second_key: '<p class="evil"><a style="color: red">Hello!</a></p>'
    }
    expected_output = {
      first_key: 'Hello!',
      second_key: 'Hello!',
    }

    actual_output = ParamSanitizer.new(input).sanitize
    assert_equal expected_output, actual_output
  end

  test "it supports nested hashes" do
    input = {
      first_key: '<p class="evil">Hello!</p>',
      second_key: '<p class="evil"><a style="color: red">Hello!</a></p>',
      first_child: {
        first_child_key: '<p class="evil">Hello!</p>',
        second_child_key: '<p class="evil"><a style="color: red">Hello!</a></p>',
      }
    }

    expected_output = {
      first_key: 'Hello!',
      second_key: 'Hello!',
      first_child: {
        first_child_key: 'Hello!',
        second_child_key: 'Hello!'
      }
    }

    actual_output = ParamSanitizer.new(input).sanitize
    assert_equal expected_output, actual_output
  end

  test "it correct sanitizes a hash with indifferent access" do
  end
end