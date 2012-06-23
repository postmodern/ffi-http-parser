require 'ffi/http/parser/types'
require 'ffi/http/parser/settings'
require 'ffi/http/parser/state'

require 'ffi'

module FFI
  module HTTP
    module Parser
      extend FFI::Library

      ffi_lib ['http_parser', 'http_parser.so.1']

      attach_function :http_parser_init, [:pointer, :http_parser_type], :void
      attach_function :http_parser_execute, [:pointer, :pointer, :pointer, :size_t], :size_t

      attach_function :http_should_keep_alive, [:pointer], :int
      attach_function :http_method_str, [:http_method], :string

    end
  end
end
