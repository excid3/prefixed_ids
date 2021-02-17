require "test_helper"

class PrefixedIdsTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert PrefixedIds::VERSION
  end

  test "default alphabet" do
    assert_equal 62, PrefixedIds.alphabet.length
  end

  test "default minimum length" do
    assert_equal 24, PrefixedIds.minimum_length
  end

  test "has a prefix ID" do
    prefix_id = User.create.prefix_id
    assert_not_nil prefix_id
    assert prefix_id.start_with?("user_")
  end

  test "can lookup by prefix ID" do
    user = User.create
    assert_equal user, User.find_by_prefix_id(user.prefix_id)
  end

  test "to param" do
    assert User.create.to_param.start_with?("user_")
  end

  test "overridden finders" do
    user = User.create
    assert_equal user, User.find(user.prefix_id)
  end

  test "overridden finders with multiple args" do
    user = User.create
    user2 = User.create
    assert_equal [user, user2], User.find(user.prefix_id, user2.prefix_id)
  end

  test "minimum length" do
    assert_equal 32 + 5, Account.create.prefix_id.length
  end

  test "doesn't override find when disabled" do
    assert_raises ActiveRecord::RecordNotFound do
      Account.find Account.create.prefix_id
    end
  end

  test "doesn't override to_param when disabled" do
    account = Account.create
    assert_not_equal account.prefix_id, account.to_param
  end
end
