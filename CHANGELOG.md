### Unreleased

* Fix decoding to require the model's own prefix. Previously, `find`, `find_by_prefix_id`, and `exists?` accepted a prefix ID with the wrong prefix or no prefix at all, as long as the hash decoded. These now return `nil` or raise `ActiveRecord::RecordNotFound`, matching other invalid IDs.

* Fix `Hashids::InputError` being raised from finders when a prefix ID contains characters outside the alphabet. Invalid IDs now return `nil` or raise `ActiveRecord::RecordNotFound` instead.

* [Breaking] Raise `PrefixedIds::Error` when two models use the same prefix. Previously, `PrefixedIds.find` silently used whichever model was defined last.

* Fix `exists?` with prefix IDs. It now works on relations and associations, can be called without arguments, and respects `fallback`. With `fallback: true` (the default), regular IDs as strings like `exists?("123")` now return `true`, matching `find`. With `fallback: false`, strings that aren't valid prefix IDs return `false`.

```ruby
user.posts.exists?("post_1234")
```

* Add `PrefixedIds.decode_prefix_id` to decode a prefix ID for any model

```ruby
PrefixedIds.decode_prefix_id("user_1234") #=> 1
```

* Add `prefix_id` to associations

```ruby
Post.create(user_prefix_id: "user_1234")
post.user_prefix_id
```

* Add `prefix_ids` to relations

```ruby
Post.all.prefix_ids #=> ["post_1234", "post_5678"]
```

### 1.8.1

* Ensure that decode returns all parts of composite key

### 1.8.0

* Add composite key support #70

### 1.7.1

* Safely handle `to_param` for new records #69

### 1.7.0

* Add `exist?` override #62 @luizkowalski

### 1.6.1

* `find` override now handles arrays

### 1.6.0

* Add `prefix_id` and `prefix_ids` class methods - @TastyPi

### 1.5.1

* [FIX] Fixes an exception that occurs when you invoke find on a non prefixed association of a prefixed_id model. #49 - @MishaConway

### 1.5.0

* Add `has_prefix_id fallback: false` option to disable lookup by regular ID - @excid3

### 1.4.0

* Add `decode_prefix_id` and `decode_prefix_ids` class methods - @TastyPi

### 1.3.0

* Add `PrefixedIds.salt` and `has_prefix_id salt: ""` option - @domchristie

### 1.2.2

* [FIX] Override find method on ActiveRecord::Relation - @excid3
* [FIX] Override find method on has_many associations - @excid3

### 1.2.1

* [FIX] Fallback to ID when overriding find so fixtures still work - @excid3
* [ADD] Add `PrefixedIds.delimiter` to be able to change the default delimiter - @rbague
* [FIX] Custom alphabet was not being used to generate the prefixed_id - @rbague

### 1.2.0

* Add `PrefixedIds.find` to lookup any model by prefixed ID

### 1.1.0

* Refactor to use Hashids and drop database column requirement

### 1.0.1

* Fix error for minimum length

### 1.0.0

* Initial release
