### 0.2.0 / 2012-06-25

* Default {FFI::HTTP::Parser::Instance#type} to `:both`, for compatibility
  with [http-parser-lite].
* {FFI::HTTP::Parser::Instance#reset!} now accepts a new type argument,
  for compatibility with [http-parser-lite].

### 0.1.0 / 2012-06-23

* Initial release:
  * Provides the same API as [http-parser-lite].
  * Supports:
    * Ruby 1.8.7
    * Ruby >= 1.9.1
    * JRuby >= 1.6.7

[http-parser]: https://github.com/joyent/http-parser#readme
[http-parser-lite]: https://github.com/deepfryed/http-parser-lite#readme
