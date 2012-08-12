require 'ffi/http/parser/parser'
require 'ffi/http/parser/settings'

require 'ffi'

module FFI
  module HTTP
    module Parser
      class Instance < FFI::Struct

        layout :type_flags,   :uchar,
               :state,        :uchar,
               :header_state, :uchar,
               :index,        :uchar,

               :nread,          :uint32,
               :content_length, :int64,

               # READ-ONLY
               :http_major,  :ushort,
               :http_minor,  :ushort,
               :status_code, :ushort, # responses only
               :method,      :uchar,  # requests only

               # 1 = Upgrade header was present and the parser has exited because of that.
               # 0 = No upgrade header present.
               #
               # Should be checked when http_parser_execute() returns in addition to
               # error checking.
               :upgrade,     :char,

               # PUBLIC
               :data, :pointer

        # The parser type (`:request`, `:response` or `:both`)
        attr_accessor :type

        #
        # Initializes the Parser instance.
        #
        # @param [FFI::Pointer] ptr
        #   Optional pointer to an existing `http_parser` struct.
        #
        def initialize(ptr=nil)
          if ptr then super(ptr)
          else
            super()

            self.type = :both
          end

          @settings = Settings.new

          yield self if block_given?

          Parser.http_parser_init(self,type) unless ptr
        end

        #
        # Registers an `on_message_begin` callback.
        #
        # @yield []
        #   The given block will be called when the HTTP message begins.
        #
        def on_message_begin(&block)
          @settings[:on_message_begin] = Callback.new(&block)
        end

        #
        # Registers an `on_path` callback.
        #
        # @yield [path]
        #   The given block will be called when the path is recognized within
        #   the Request URI.
        #
        # @yieldparam [String] path
        #   The recognized URI path.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2
        #
        def on_path(&block)
          @settings[:on_path] = DataCallback.new(&block)
        end

        #
        # Registers an `on_query_string` callback.
        #
        # @yield [query]
        #   The given block will be called when the query-string is recognized
        #   within the Request URI.
        #
        # @yieldparam [String] query
        #   The recognized URI query-string.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2
        #
        def on_query_string(&block)
          @settings[:on_query_string] = DataCallback.new(&block)
        end

        #
        # Registers an `on_fragment` callback.
        #
        # @yield [fragment]
        #   The given block will be called when the fragment is recognized
        #   within the Request URI.
        #
        # @yieldparam [String] fragment
        #   The recognized URI fragment.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2
        #
        def on_fragment(&block)
          @settings[:on_fragment] = DataCallback.new(&block)
        end

        #
        # Registers an `on_url` callback.
        #
        # @yield [url]
        #   The given block will be called when the Request URI is recognized
        #   within the Request-Line.
        #
        # @yieldparam [String] url
        #   The recognized Request URI.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2
        #
        def on_url(&block)
          @settings[:on_url] = DataCallback.new(&block)
        end

        #
        # Registers an `on_header_field` callback.
        #
        # @yield [field]
        #   The given block will be called when a Header name is recognized
        #   in the Headers.
        #
        # @yieldparam [String] field
        #   A recognized Header name.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.5
        #
        def on_header_field(&block)
          @settings[:on_header_field] = DataCallback.new(&block)
        end

        #
        # Registers an `on_header_value` callback.
        #
        # @yield [value]
        #   The given block will be called when a Header value is recognized
        #   in the Headers.
        #
        # @yieldparam [String] value
        #   A recognized Header value.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.5
        #
        def on_header_value(&block)
          @settings[:on_header_value] = DataCallback.new(&block)
        end

        #
        # Registers an `on_headers_complete` callback.
        #
        # @yield []
        #   The given block will be called when the Headers stop.
        #
        def on_headers_complete(&block)
          @settings[:on_headers_complete] = Callback.new(&block)
        end

        #
        # Registers an `on_body` callback.
        #
        # @yield [body]
        #   The given block will be called when the body is recognized in the
        #   message body.
        #
        # @yieldparam [String] body
        #   The full body or a chunk of the body from a chunked
        #   Transfer-Encoded stream.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.5
        #
        def on_body(&block)
          @settings[:on_body] = DataCallback.new(&block)
        end

        #
        # Registers an `on_message_begin` callback.
        #
        # @yield []
        #   The given block will be called when the message completes.
        #
        def on_message_complete(&block)
          @settings[:on_message_complete] = Callback.new(&block)
        end

        #
        # Parses data.
        #
        # @param [String] data
        #   The data to parse.
        #
        # @return [Integer]
        #   The number of bytes parsed. `0` will be returned if the parser
        #   encountered an error.
        #
        def parse(data)
          Parser.http_parser_execute(self,@settings,data,data.length)
        end

        #
        # Parses data.
        #
        # @param [String] data
        #   The data to parse.
        #
        # @return [Instance]
        #   The Instance parser.
        #
        def <<(data)
          parse(data)
          return self
        end

        #
        # Resets the parser.
        #
        # @param [:request, :response, :both] new_type
        #   The new type for the parser.
        #
        def reset!(new_type=self.type)
          Parser.http_parser_init(self,new_type)
        end

        alias reset reset!

        #
        # The type of the parser.
        #
        # @return [:request, :response, :both]
        #   The parser type.
        #
        def type
          TYPES[self[:type_flags] & 0x3]
        end

        #
        # Sets the type of the parser.
        #
        # @param [:request, :response, :both] new_type
        #   The new parser type.
        #
        def type=(new_type)
          self[:type_flags] = ((flags << 2) | TYPES[new_type])
        end

        #
        # Flags for the parser.
        #
        # @return [Integer]
        #   Parser flags.
        #
        def flags
          (self[:type_flags] & 0xfc) >> 2
        end

        #
        # The parsed HTTP major version number.
        #
        # @return [Integer]
        #   The HTTP major version number.
        #
        def http_major
          self[:http_major]
        end

        #
        # The parsed HTTP minor version number.
        #
        # @return [Integer]
        #   The HTTP minor version number.
        #
        def http_minor
          self[:http_minor]
        end

        #
        # The parsed HTTP version.
        #
        # @return [String]
        #   The HTTP version.
        #
        def http_version
          "%d.%d" % [self[:http_major], self[:http_minor]]
        end

        #
        # The parsed HTTP response Status Code.
        #
        # @return [Integer]
        #   The HTTP Status Code.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6.1.1
        #
        def http_status
          self[:status_code]
        end

        #
        # The parsed HTTP Method.
        #
        # @return [Symbol]
        #   The HTTP Method name.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.1
        #
        def http_method
          METHODS[self[:method]]
        end

        #
        # Determines whether the `Upgrade` header has been parsed.
        #
        # @return [Boolean]
        #   Specifies whether the `Upgrade` header has been seen.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.42
        #
        def upgrade?
          self[:upgrade] == 1
        end

        #
        # Additional data attached to the parser.
        #
        # @return [FFI::Pointer]
        #   Pointer to the additional data.
        #
        def data
          self[:data]
        end

        #
        # Determines whether the `Connection: keep-alive` header has been
        # parsed.
        #
        # @return [Boolean]
        #   Specifies whether the Connection should be kept alive.
        #
        # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.10
        #
        def keep_alive?
          Parser.http_should_keep_alive(self) > 0
        end

        #
        # Halts the parser.
        #
        # @since 0.3.0
        #
        def stop!
          throw :return, 1
        end

        #
        # Indicates an error has occurred.
        #
        # @since 0.3.0
        #
        def error!
          throw :return, -1
        end

        protected

        #
        # @since 0.3.0
        #
        class Callback < Proc

          #
          # Creates a new Parser callback.
          #
          def self.new(&block)
            super do |parser|
              catch(:return) { yield; 0 }
            end
          end

        end

        #
        # @since 0.3.0
        #
        class DataCallback < Proc

          def self.new(&block)
            super do |parser,buffer,length|
              data = buffer.get_bytes(0,length)

              catch(:return) { yield(data); 0 }
            end
          end

        end

      end
    end
  end
end
