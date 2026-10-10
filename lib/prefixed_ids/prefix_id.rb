module PrefixedIds
  class PrefixId
    attr_reader :hashids, :prefix

    TOKEN = 123

    def initialize(model, prefix, salt: PrefixedIds.salt, minimum_length: PrefixedIds.minimum_length, alphabet: PrefixedIds.alphabet, delimiter: PrefixedIds.delimiter, **options)
      @prefix = prefix.to_s
      @delimiter = delimiter.to_s
      @hashids = Hashids.new("#{model.table_name}#{salt}", minimum_length, alphabet)
    end

    def encode(id)
      return if id.nil?

      @prefix + @delimiter + @hashids.encode([TOKEN] + Array.wrap(id))
    end

    # decode returns an array
    def decode(id, fallback: false)
      fallback_value = fallback ? id : nil
      prefix, id_without_prefix = PrefixedIds.split_id(id, @delimiter)

      # Reject IDs whose prefix isn't ours, even if the hash would decode
      return fallback_value unless prefix == @prefix

      decoded_hashid = decode_hashid(id_without_prefix)

      if !valid?(decoded_hashid)
        fallback_value
      else
        _, *ids = decoded_hashid
        (ids.size == 1) ? ids.first : ids
      end
    end

    private

    # Bad characters from user input shouldn't blow up finders
    def decode_hashid(hashid)
      @hashids.decode(hashid)
    rescue Hashids::InputError
      []
    end

    def valid?(decoded_hashid)
      decoded_hashid.size >= 2 && decoded_hashid.first == TOKEN
    end
  end
end
