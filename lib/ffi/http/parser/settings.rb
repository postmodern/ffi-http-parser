require 'ffi/http/parser/types'

module FFI
  module HTTP
    class Parser
      class Settings < FFI::Struct

        layout :on_message_begin,    :http_cb,
               :on_path,             :http_data_cb,
               :on_query_string,     :http_data_cb,
               :on_url,              :http_data_cb,
               :on_fragment,         :http_data_cb,
               :on_header_field,     :http_data_cb,
               :on_header_value,     :http_data_cb,
               :on_headers_complete, :http_cb,
               :on_body,             :http_data_cb,
               :on_message_complete, :http_cb

      end
    end
  end
end
