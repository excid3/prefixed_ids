require "test_helper"

class PrefixedIdsTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert PrefixedIds::VERSION
  end

  test "has a prefix ID" do
    prefix_id = User.create.prefix_id
    assert_not_nil prefix_id
    assert prefix_id.start_with?("user_")
  end

  test "customizable attribute name" do
    da = DifferentAttribute.create
    assert_not_nil da.attribute_id
    assert da.attribute_id.start_with?("diff_")
  end

  test "default length" do
    prefix_id = User.create.prefix_id
    assert_equal PrefixedIds::MINIMUM_TOKEN_LENGTH + 5, prefix_id.length
  end

  test "customizable length" do
    assert_equal 37, Account.create.prefix_id.length
  end

  test "raises error under minimum length" do
    assert_raises PrefixedIds::MinimumLengthError do
      # Lazily loaded so this shouldn't error until we access it
      InvalidLength.create
    end
  end
end
