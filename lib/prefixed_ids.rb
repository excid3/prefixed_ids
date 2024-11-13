require "prefixed_ids/version"
require "prefixed_ids/engine"

require "hashids"

module PrefixedIds
  class Error < StandardError; end

  autoload :PrefixId, "prefixed_ids/prefix_id"

  mattr_accessor :delimiter, default: "_"
  mattr_accessor :alphabet, default: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
  mattr_accessor :minimum_length, default: 24
  mattr_accessor :salt, default: ""

  mattr_accessor :models, default: {}

  def self.find(prefix_id)
    prefix, = split_id(prefix_id)
    models.fetch(prefix).find_by_prefix_id(prefix_id)
  rescue KeyError
    raise Error, "Unable to find model with prefix `#{prefix}`. Available prefixes are: #{models.keys.join(', ')}"
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
      class_attribute :_prefix_id_fallback
    end

    class_methods do
      def has_prefix_id(prefix, override_find: true, override_param: true, fallback: true, **options)
        include Attribute
        include Finder if override_find
        include ToParam if override_param

        self._prefix_id = PrefixId.new(self, prefix, **options)
        self._prefix_id_fallback = fallback

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

      def prefix_id(id)
        _prefix_id.encode(id)
      end

      def prefix_ids(ids)
        ids.map { |id| prefix_id(id) }
      end

      def decode_prefix_id(id)
        _prefix_id.decode(id)
      end

      def decode_prefix_ids(ids)
        ids.map { |id| decode_prefix_id(id) }
      end
    end

    def prefix_id
      _prefix_id.encode(id)
    end
  end

  module Finder
    extend ActiveSupport::Concern

    class_methods do
      def find(*ids)
        # Skip if model doesn't use prefixed ids
        return super if _prefix_id.blank?

        prefix_ids = ids.flatten.map do |id|
          prefix_id = _prefix_id.decode(id, fallback: _prefix_id_fallback)
          raise Error, "#{id} is not a valid prefix_id" if !_prefix_id_fallback && prefix_id.nil?

          prefix_id
        end
        prefix_ids = [prefix_ids] if ids.first.is_a?(Array)

        super(*prefix_ids)
      end

      def relation
        super.tap { |r| r.extend ClassMethods }
      end

      def belongs_to(*args, **options, &)
        association = super

        name = args.first
        reflection = association[name]

        return association if reflection.polymorphic?
        return association if reflection.klass._prefix_id.blank?

        generated_association_methods.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}_prefix_id
            #{reflection.klass}._prefix_id.encode(#{reflection.foreign_key})
          end

          def #{name}_prefix_id=(prefix_id)
            decoded_id = #{reflection.klass}._prefix_id.decode(prefix_id, fallback: #{reflection.klass}._prefix_id_fallback)
            send("#{reflection.foreign_key}=", decoded_id)
          end
        CODE

        association
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
