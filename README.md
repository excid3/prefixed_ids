<p align="center">
  <h1>Prefixed IDs</h1>
</p>

### 🆔 Friendly Prefixed IDs for your Ruby on Rails models

[![Build Status](https://github.com/excid3/prefixed_ids/workflows/Tests/badge.svg)](https://github.com/excid3/prefixed_ids/actions) [![Gem Version](https://badge.fury.io/rb/prefixed_ids.svg)](https://badge.fury.io/rb/prefixed_ids)

Generate prefixed IDs for your models with a friendly prefix. For example:

```ruby
user_12345abcd
acct_23lksjdg3
```

This gem works by hashing the record's original `:id` attribute using [`Hashids`](https://hashids.org/ruby/), which transforms numbers like 347 into a string like yr8. It uses the table's name and an optional additional salt to hash values, returning a string like `tablename_hashedvalue`.

Inspired by [Stripe's prefixed IDs](https://stripe.com/docs/api) in their API.

## 🚀 Installation
Add this line to your application's Gemfile:

```ruby
gem 'prefixed_ids'
```

## 📝 Usage

Add `has_prefix_id :my_prefix` to your models to autogenerate prefixed IDs.

```ruby
class User < ApplicationRecord
  has_prefix_id :user
end
```

This will generate a value like `user_1234abcd`.

##### Prefix ID Param

To retrieve the prefix ID, simply call:

```ruby
User.to_param
```

If `to_param` override is disabled:

```ruby
User.prefix_id
```

##### Query by Prefixed ID

To query using the prefixed ID, you can use either `find`, `find_by_prefix_id`, or `find_by_prefix_id!`:

```ruby
User.find("user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe")
User.find_by_prefix_id("user_5vJjbzXq9KrLEMm32iAnOP0xGDYk6dpe")
```

⚠️ Note that `find` still finds records by the primary key. Eg. `localhost/users/1` still works. 
If you're targeting security issues by masking the ID, make sure to use `find_by_prefix_id` and [add a salt](#salt).

We also override `to_param` by default so it'll be used in URLs automatically.

To disable find and to_param overrides, simply pass in the options:

```ruby
class User < ApplicationRecord
  has_prefix_id :user, override_find: false, override_param: false
end
```

##### Salt

A salt is a secret value that makes it impossible to reverse engineer IDs. We recommend adding a salt to make your Prefix IDs unguessable.

###### Global Salt

```ruby
# config/initializers/prefixed_ids.rb
PrefixedIds.salt = "salt"
```

###### Per Model Salt

```ruby
class User
  has_prefix_id :user, salt: "usersalt"
end
```

### Generic Lookup By Prefix ID

Imagine you have a prefixed ID but you don't know which model it belongs to.

```ruby
PrefixedIds.find("user_5vJjbzXq9KrLEMm3")
#=> #<User>
PrefixedIds.find("acct_2iAnOP0xGDYk6dpe")
#=> #<Account>
```

### Customizing Prefix IDs

You can customize the prefix, length, and attribute name for PrefixedIds.

```ruby
class Account < ApplicationRecord
  has_prefix_id :acct, minimum_length: 32, override_find: false, override_param: false, salt: ""
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## 🙏 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/excid3/prefixed_ids. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/prefixed_ids/blob/master/CODE_OF_CONDUCT.md).

## 📝 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PrefixedIds project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/prefixed_ids/blob/master/CODE_OF_CONDUCT.md).
