require 'ffi/http/parser/library'
require 'ffi/http/parser/instance'

module FFI
  module HTTP
    module Parser
      #
      # Creates a new Parser.
      #
      # @return [Instance]
      #   A new parser instance.
      #
      # @see Instance
      #
      def self.new(&block)
        Instance.new(&block)
      end

    end
  end
end
