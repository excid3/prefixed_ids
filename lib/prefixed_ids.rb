require "prefixed_ids/version"
require "prefixed_ids/engine"

require "hashids"

module PrefixedIds
  TOKEN = 123

  mattr_accessor :alphabet, default: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
  mattr_accessor :minimum_length, default: 24

  class PrefixId
    attr_reader :hashids, :model, :prefix

    def initialize(model, prefix, minimum_length: PrefixedIds.minimum_length, alphabet: PrefixedIds.alphabet, **options)
      @alphabet = alphabet
      @model = model
      @prefix = prefix.to_s
      @hashids = Hashids.new(model.table_name, minimum_length)
    end

    def encode(id)
      prefix + "_" + @hashids.encode(TOKEN, id)
    end

    # decode returns an array
    def decode(id, fallback: false)
      fallback_value = fallback ? id : nil
      id_without_prefix = id.to_s.rpartition("_").last
      decoded_id = @hashids.decode(id_without_prefix).last
      decoded_id || fallback_value
    end
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
        super(*ids.map { |id| _prefix_id.decode(id) })
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
