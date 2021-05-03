### Unreleased

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
