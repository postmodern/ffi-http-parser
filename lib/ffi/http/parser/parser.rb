require 'ffi/http/parser/types'
require 'ffi/http/parser/settings'
require 'ffi/http/parser/state'

require 'ffi'

module FFI
  module HTTP
    class Parser
      extend FFI::Library

      ffi_lib ['http_parser', 'http_parser.so.1']

      attach_function :http_parser_init, [:pointer, :http_parser_type], :void
      attach_function :http_parser_execute, [:pointer, :pointer, :pointer, :size_t], :size_t

      attach_function :http_should_keep_alive, [:pointer], :int
      attach_function :http_method_str, [:http_method], :string

      def initialize(type=:both)
        @type     = type
        @state    = State.new
        @settings = Settings.new

        Parser.http_parser_init(@state,@type)

        yield self if block_given?
      end

      def on_message_begin(&block)
        @settings[:on_message_begin] = wrap_callback(&block)
      end

      def on_path(&block)
        @settings[:on_path] = wrap_data_callback(&block)
      end

      def on_query_string(&block)
        @settings[:on_query_string] = wrap_data_callback(&block)
      end

      def on_url(&block)
        @settings[:on_url] = wrap_data_callback(&block)
      end

      def on_fragment(&block)
        @settings[:on_fragment] = wrap_data_callback(&block)
      end

      def on_header_field(&block)
        @settings[:on_header_field] = wrap_data_callback(&block)
      end

      def on_header_value(&block)
        @settings[:on_header_value] = wrap_data_callback(&block)
      end

      def on_headers_complete(&block)
        @settings[:on_headers_complete] = proc { |state|
          (block.call(@state) == :stop) ? 1 : 0
        }
      end

      def on_body(&block)
        @settings[:on_body] = wrap_data_callback(&block)
      end

      def on_message_complete(&block)
        @settings[:on_message_complete] = wrap_callback(&block)
      end

      def reset!
        Parser.http_parser_init(@state,@type)
      end

      def <<(data)
        self.class.http_parser_execute(@state,@settings,data,data.length)
      end

      protected

      def wrap_callback(&block)
        proc { |state| (block.call(@state) == :error) ? -1 : 0 }
      end

      def wrap_data_callback(&block)
        proc { |state,buffer,length|
          data = buffer.get_bytes(0,length)

          (block.call(@state,data) == :error) ? -1 : 0
        }
      end

    end
  end
end
