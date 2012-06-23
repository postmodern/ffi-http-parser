require 'ffi'

module FFI
  module HTTP
    module Parser
      extend FFI::Library

      HTTP_MAX_HEADER_SIZE = (80 * 1024)

      callback :http_data_cb, [:pointer, :pointer, :size_t], :int
      callback :http_cb, [:pointer], :int

      enum :http_method, [
        :DELETE,
        :GET,
        :HEAD,
        :POST,
        :PUT,
        # pathological
        :CONNECT,
        :OPTIONS,
        :TRACE,
        # webdav
        :COPY,
        :LOCK,
        :MKCOL,
        :MOVE,
        :PROPFIND,
        :PROPPATCH,
        :UNLOCK,
        # subversion
        :REPORT,
        :MKACTIVITY,
        :CHECKOUT,
        :MERGE,
        # upnp
        :MSEARCH,
        :NOTIFY,
        :SUBSCRIBE,
        :UNSUBSCRIBE
      ]

      enum :http_parser_type, [:request, :response, :both]

    end
  end
end
