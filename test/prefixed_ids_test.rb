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

  test "default salt" do
    assert_equal "", PrefixedIds.salt
  end

  test "can get prefix ID from original ID" do
    assert_equal users(:one).prefix_id, User.prefix_id(users(:one).id)
  end

  test "can get prefix IDs from multiple original IDs" do
    assert_equal(
      [users(:one).prefix_id, users(:two).prefix_id, users(:three).prefix_id],
      User.prefix_ids([users(:one).id, users(:two).id, users(:three).id])
    )
  end

  test "can get original ID from prefix ID" do
    assert_equal users(:one).id, User.decode_prefix_id(users(:one).prefix_id)
  end

  test "can get original IDs from multiple prefix IDs" do
    assert_equal(
      [users(:one).id, users(:two).id, users(:three).id],
      User.decode_prefix_ids([users(:one).prefix_id, users(:two).prefix_id, users(:three).prefix_id])
    )
  end

  test "has a prefix ID" do
    prefix_id = users(:one).prefix_id
    assert_not_nil prefix_id
    assert prefix_id.start_with?("user_")
  end

  test "can lookup by prefix ID" do
    user = users(:one)
    assert_equal user, User.find_by_prefix_id(user.prefix_id)
  end

  test "to param" do
    assert users(:one).to_param.start_with?("user_")
  end

  test "overridden finders" do
    user = users(:one)
    assert_equal user, User.find(user.prefix_id)
  end

  test "overridden finders with multiple args" do
    user = users(:one)
    user2 = users(:two)
    assert_equal [user, user2], User.find(user.prefix_id, user2.prefix_id)
  end

  test "overridden finders with array args" do
    user = users(:one)
    user2 = users(:two)
    assert_equal [user, user2], User.find([user.prefix_id, user2.prefix_id])
  end

  test "overridden finders with single array args" do
    user = users(:one)
    assert_equal [user], User.find([user.prefix_id])
  end

  test "minimum length" do
    assert_equal 32 + 5, accounts(:one).prefix_id.length
  end

  test "doesn't override find when disabled" do
    assert_raises ActiveRecord::RecordNotFound do
      Account.find accounts(:one).prefix_id
    end
  end

  test "doesn't override to_param when disabled" do
    account = accounts(:one)
    assert_not_equal account.prefix_id, account.to_param
  end

  test "find looks up the correct model" do
    user = users(:one)
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

  test "can change the default delimiter" do
    slash = PrefixedIds::PrefixId.new(User, "user", delimiter: "/")

    assert slash.encode(1).start_with?("user/")
  end

  test "can use a custom salt" do
    default_encoder = PrefixedIds::PrefixId.new(User, "user")
    custom_encoder = PrefixedIds::PrefixId.new(User, "user", salt: "truffle")

    default = default_encoder.encode(1)
    custom = custom_encoder.encode(1)

    assert_not_equal default, custom
    assert_equal default_encoder.decode(default), custom_encoder.decode(custom)
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

  test "works with relations" do
    user = users(:one)
    assert_equal user, User.default_scoped.find(user.to_param)
  end

  test "works with has_many" do
    user = users(:one)
    post = user.posts.first
    assert_equal post, user.posts.find(post.to_param)
  end

  test "can override salt on model" do
    assert_equal "accountsabcd", Account._prefix_id.hashids.salt
  end

  test "decode with fallback false returns nil for regular ID" do
    assert_nil Team._prefix_id.decode(1)
  end

  test "disabled fallback allows find by prefix id" do
    team = Team.find_by(id: ActiveRecord::FixtureSet.identify(:one))
    assert_equal team, Team.find(team.prefix_id)
  end

  test "disabled fallback raises an error if not prefix_id" do
    assert_raises PrefixedIds::Error do
      Team.find(ActiveRecord::FixtureSet.identify(:one))
    end
  end

  test "find by prefixed ID on association" do
    account = accounts(:one)
    assert_equal account, account.user.accounts.find(account.prefix_id)
  end

  test "calling find on an associated model without prefix id succeeds" do
    nonprefixed_item = nonprefixed_items(:one)
    user = users(:one)

    assert_equal user.nonprefixed_items.find(nonprefixed_item.id), nonprefixed_item
    assert_raises(ActiveRecord::RecordNotFound) { user.nonprefixed_items.find(9999999) }
  end

  test "calling to_param on non-persisted record" do
    assert_nil Post.new.to_param
  end

  test "helper for getting prefix ID from belongs to models when associated model has prefix ID" do
    post = posts(:one)
    assert_equal post.user_prefix_id, post.user.prefix_id
  end

  test "no helper for getting prefix ID from belongs to models when associated model does not have prefix ID" do
    post = posts(:one)
    assert_raises NoMethodError do
      post.nonprefixed_item_prefix_id
    end
  end

  test "setter for using prefix ID while creating models with mass assignment" do
    post = Post.create!(user_prefix_id: users(:two).prefix_id)
    assert_equal users(:two), post.user
  end

  test "no setter for using prefix ID while creating models with mass assignment when associated model does not have prefix ID" do
    assert_raises ActiveModel::UnknownAttributeError do
      Post.create!(user: users(:two), nonprefixed_item_prefix_id: "abc123")
    end
  end

  test "setter for belongs to models that have prefix IDs" do
    post = Post.new
    post.user_prefix_id = users(:two).prefix_id
    assert_equal users(:two), post.user
  end

  test "setter not created on models without has_prefix_id" do
    assert_raises NoMethodError do
      NonprefixedItem.new.user_prefix_id
    end
  end

  test "setter not created on polymorphic belongs to models" do
    assert_raises NoMethodError do
      Tag.new.taggable_prefix_id
    end
  end

  test "can retrieve a decoded ID from a prefixed ID" do
    team = Team.find_by(id: ActiveRecord::FixtureSet.identify(:one))
    assert_equal PrefixedIds.decode_prefix_id(team.prefix_id), team.id
  end

  test "decoded id returns actual id if passed a non-prefix_id" do
    user = users(:one)
    assert_equal PrefixedIds.decode_prefix_id(user.id), user.id
  end

  if PrefixedIds::Test.rails71_and_up?
    test "compound primary - can get prefix ID from original ID" do
      assert compound_primary_items(:one).id.is_a?(Array)
      assert_equal compound_primary_items(:one).prefix_id, CompoundPrimaryItem.prefix_id(compound_primary_items(:one).id)
    end

    test "compound primary - checks for a valid id upon decoding" do
      prefix = PrefixedIds::PrefixId.new(CompoundPrimaryItem, "compound")
      hashid = Hashids.new(CompoundPrimaryItem.table_name, PrefixedIds.minimum_length, PrefixedIds.alphabet)

      first = prefix.encode([1, 1])
      second = hashid.encode([1, 1])

      assert_not_equal first.delete_prefix("compound" + PrefixedIds.delimiter), second
      assert_equal prefix.decode(second, fallback: true), second

      decoded = hashid.decode(second)
      assert_equal decoded.size, 2
      assert_equal decoded, [1, 1]

      prefix_decoded = prefix.decode(first)
      assert_equal prefix_decoded, [1, 1]
    end
  end

  test "register_prefix adds the expected prefix and model" do
    model = Class.new(ApplicationRecord) do
      def self.name
        "TestModel"
      end
    end

    PrefixedIds.register_prefix("test_model", model: model)
    assert_equal model, PrefixedIds.models["test_model"]
  end

  test "has_prefix_id raises when prefix was already used" do
    assert PrefixedIds.models.key?("user")
    assert_raises PrefixedIds::Error do
      Class.new(ApplicationRecord) do
        def self.name
          "TestModel"
        end

        has_prefix_id :user
      end
    end
  end

  test "prefix_ids on relation returns array of prefix IDs" do
    prefix_ids = User.all.prefix_ids
    assert_equal 3, prefix_ids.length
    assert prefix_ids.all? { |id| id.start_with?("user_") }
  end

  test "prefix_ids on scoped relation" do
    user = users(:one)
    prefix_ids = User.where(id: user.id).prefix_ids
    assert_equal [user.prefix_id], prefix_ids
  end

  test "prefix_ids on has_many relation" do
    user = users(:one)
    post_prefix_ids = user.posts.prefix_ids
    assert post_prefix_ids.all? { |id| id.start_with?("post_") }
  end

  test "prefix_ids on empty relation returns empty array" do
    assert_equal [], User.where(id: -1).prefix_ids
  end

  test "prefix_ids on relation with override_find: false" do
    prefix_ids = Account.all.prefix_ids
    assert prefix_ids.all? { |id| id.start_with?("acct_") }
  end

  test "prefix_ids on scoped relation with override_find: false" do
    account = accounts(:one)
    prefix_ids = Account.where(id: account.id).prefix_ids
    assert_equal [account.prefix_id], prefix_ids
  end

  test "prefix_ids on has_many association with override_find: false" do
    user = users(:one)
    account_prefix_ids = user.accounts.prefix_ids
    assert account_prefix_ids.all? { |id| id.start_with?("acct_") }
  end

  test "prefix_ids on empty relation with override_find: false" do
    assert_equal [], Account.where(id: -1).prefix_ids
  end
end
