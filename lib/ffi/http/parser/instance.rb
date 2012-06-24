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

        def initialize(ptr=nil)
          super(ptr)

          @settings = Settings.new

          yield self if block_given?

          Parser.http_parser_init(self,type) unless ptr
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
          @settings[:on_headers_complete] = proc { |parser|
            (block.call() == :stop) ? 1 : 0
          }
        end

        def on_body(&block)
          @settings[:on_body] = wrap_data_callback(&block)
        end

        def on_message_complete(&block)
          @settings[:on_message_complete] = wrap_callback(&block)
        end

        def reset!
          Parser.http_parser_init(self,type)
        end

        def <<(data)
          Parser.http_parser_execute(self,@settings,data,data.length)
        end

        def type
          TYPES[self[:type] & 0x3]
        end

        def type=(new_type)
          self[:type] = TYPES[new_type]
        end

        def http_major
          self[:http_major]
        end

        def http_minor
          self[:http_minor]
        end

        def http_version
          "%d.%d" % [self[:http_major], self[:http_minor]]
        end

        def http_status
          self[:status_code]
        end

        def http_method
          METHODS[self[:method]]
        end

        def upgrade?
          self[:upgrade] == 1
        end

        def data
          self[:data]
        end

        def keep_alive?
          Parser.http_should_keep_alive(self) > 0
        end

        protected

        def wrap_callback(&block)
          proc { |parser| (block.call() == :error) ? -1 : 0 }
        end

        def wrap_data_callback(&block)
          proc { |parser,buffer,length|
            data = buffer.get_bytes(0,length)

            (block.call(data) == :error) ? -1 : 0
          }
        end

      end
    end
  end
end
