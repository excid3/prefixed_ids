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

## Installation
Add this line to your application's Gemfile:

```ruby
bundle add 'prefixed_ids'
```

## Usage

First, you'll need to generate a migration to add the prefix_id column to your model(s).

```ruby
class AddPrefixIdToUsers< ActiveRecord::Migration
  def change
    add_index :users, :prefix_id, unique: true
  end
end
```

It's important the `prefix_id` column is indexed and unique.

Then you can add `has_prefix_id :my_prefix` to your models to autogenerate prefixed IDs.

```ruby
class User < ApplicationRecord
  has_prefix_id :user
end
```

This will generate a value like `user_1234abcd` in the User's `prefix_id` column.

### Customizing

You can customize the prefix, length, and attribute name for PrefixedIds.

```ruby
class Account < ApplicationRecord
  has_prefix_id :acct, attribute: :my_id, length: 32
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/excid3/prefixed_ids. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/prefixed_ids/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PrefixedIds project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/prefixed_ids/blob/master/CODE_OF_CONDUCT.md).

