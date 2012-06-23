require 'ffi/http/parser/types'

module FFI
  module HTTP
    class Parser
      class State < FFI::Struct
        
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
          self[:method]
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

      end
    end
  end
end
