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

  test "find looks up the correct model" do
    user = User.create
    assert_equal user, PrefixedIds.find(user.prefix_id)
  end

  test "find with invalid prefix" do
    assert_raises PrefixedIds::Error do
      PrefixedIds.find("unknown_1")
    end
  end

  test "split_id" do
    assert_equal ["user", "1234"], PrefixedIds.split_id("user_1234")
  end

  test "can use a custom alphabet" do
    default_encoder = PrefixedIds::PrefixId.new(User, "user", alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
    custom_encoder = PrefixedIds::PrefixId.new(User, "user", alphabet: "5N6y2rljDQak4xgzn8ZR1oKYLmJpEbVq3OBv9WwXPMe7")

    default = default_encoder.encode(1)
    custom = custom_encoder.encode(1)

    assert_not_equal default, custom
    assert_equal default_encoder.decode(default), custom_encoder.decode(custom)
  end

  test "can change the default delimiter delimiter" do
    slash = PrefixedIds::PrefixId.new(User, "user", delimiter: "/")

    assert slash.encode(1).start_with?("user/")
  end

  test "checks for a valid id upon decoding" do
    prefix = PrefixedIds::PrefixId.new(User, "user")
    hashid = Hashids.new(User.table_name, PrefixedIds.minimum_length, PrefixedIds.alphabet)

    first = prefix.encode(1)
    second = hashid.encode(1)

    assert_not_equal first.delete_prefix("user" + PrefixedIds.delimiter), second
    assert_equal prefix.decode(second, fallback: true), second

    decoded = hashid.decode(second)
    assert_equal decoded.size, 1
    assert_equal decoded.first, 1
  end

  # See https://github.com/jcypret/hashid-rails/pull/46/files
  test "works with fixtures" do
    assert_nothing_raised do
      users(:one)
    end
  end
end
