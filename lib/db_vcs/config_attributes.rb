# frozen_string_literal: true

module DbVcs
  module ConfigAttributes
    # Assigns config attributes from hash.
    # @param hash [Hash]
    #   Example:
    #     {
    #       environments: ["development"],
    #       pg_config: {
    #         port: 5433
    #       }
    #     }
    # @return [void]
    def assign_attributes(hash)
      hash.each do |k, v|
        if public_methods(false).include?(:"#{k}=")
          public_send(:"#{k}=", v)
        end
      end
    end
  end
end
