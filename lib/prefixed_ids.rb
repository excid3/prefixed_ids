require "prefixed_ids/version"
require "prefixed_ids/engine"

require "hashids"

module PrefixedIds
  class Error < StandardError; end

  autoload :PrefixId, "prefixed_ids/prefix_id"

  mattr_accessor :delimiter, default: "_"
  mattr_accessor :alphabet, default: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
  mattr_accessor :minimum_length, default: 24

  mattr_accessor :models, default: {}

  def self.find(prefix_id)
    prefix, _ = split_id(prefix_id)
    models.fetch(prefix).find_by_prefix_id(prefix_id)
  rescue KeyError
    raise Error, "Unable to find model with prefix `#{prefix}`. Available prefixes are: #{models.keys.join(", ")}"
  end

  # Splits a prefixed ID into its prefix and ID
  def self.split_id(prefix_id, delimiter = PrefixedIds.delimiter)
    prefix, _, id = prefix_id.to_s.rpartition(delimiter)
    [prefix, id]
  end

  # Adds `has_prefix_id` method
  module Rails
    extend ActiveSupport::Concern

    included do
      class_attribute :_prefix_id
    end

    class_methods do
      def has_prefix_id(prefix, override_find: true, override_param: true, **options)
        include Attribute
        include Finder if override_find
        include ToParam if override_param
        self._prefix_id = PrefixId.new(self, prefix, **options)

        # Register with PrefixedIds to support PrefixedIds#find
        PrefixedIds.models[prefix.to_s] = self
      end
    end
  end

  # Included when a module uses `has_prefix_id`
  module Attribute
    extend ActiveSupport::Concern

    class_methods do
      def find_by_prefix_id(id)
        find_by(id: _prefix_id.decode(id))
      end

      def find_by_prefix_id!(id)
        find_by!(id: _prefix_id.decode(id))
      end
    end

    def prefix_id
      self.class._prefix_id.encode(id)
    end
  end

  module Finder
    extend ActiveSupport::Concern

    class_methods do
      def find(*ids)
        super(*ids.map { |id| _prefix_id.decode(id, fallback: true) })
      end

      def relation
        super.tap { |r| r.extend ClassMethods }
      end

      def has_many(*args, &block)
        options = args.extract_options!
        options[:extend] = Array(options[:extend]).push(ClassMethods)
        super(*args, **options, &block)
      end
    end
  end

  module ToParam
    extend ActiveSupport::Concern

    def to_param
      _prefix_id.encode(id)
    end
  end
end
