module PrefixedIds
  class PrefixId
    attr_reader :hashids, :prefix

    TOKEN = 123

    def initialize(model, prefix, minimum_length: PrefixedIds.minimum_length, alphabet: PrefixedIds.alphabet, delimiter: PrefixedIds.delimiter, **options)
      @prefix = prefix.to_s
      @delimiter = delimiter.to_s
      @hashids = Hashids.new(model.table_name, minimum_length, alphabet)
    end

    def encode(id)
      @prefix + @delimiter + @hashids.encode(TOKEN, id)
    end

    # decode returns an array
    def decode(id, fallback: false)
      fallback_value = fallback ? id : nil
      _, id_without_prefix = PrefixedIds.split_id(id, @delimiter)
      decoded_hashid = @hashids.decode(id_without_prefix)
      return fallback_value unless valid?(decoded_hashid)

      decoded_hashid.last || fallback_value
    end

    private

    def valid?(decoded_hashid)
      decoded_hashid.size == 2 && decoded_hashid.first == TOKEN
    end
  end
end
