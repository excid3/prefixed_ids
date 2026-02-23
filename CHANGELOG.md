### Unreleased

### 1.9.0

* [Breaking] Remove `exists?` override.

To continue using `exists?`, you can decode the ID first:

```ruby
User.exists? User.decode_prefix_id(params[:id])
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
