require 'ffi'

module FFI
  module HTTP
    module Parser
      extend FFI::Library

      HTTP_MAX_HEADER_SIZE = (80 * 1024)

      callback :http_data_cb, [:pointer, :pointer, :size_t], :int
      callback :http_cb, [:pointer], :int

      enum :http_method, [
        :delete,
        :get,
        :head,
        :post,
        :put,
        # pathological
        :connect,
        :options,
        :trace,
        # webdav
        :copy,
        :lock,
        :mkcol,
        :move,
        :propfind,
        :proppatch,
        :unlock,
        # subversion
        :report,
        :mkactivity,
        :checkout,
        :merge,
        # upnp
        :msearch,
        :notify,
        :subscribe,
        :unsubscribe
      ]

      enum :http_parser_type, [:request, :response, :both]

    end
  end
end
