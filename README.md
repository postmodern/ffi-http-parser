# ffi-http-parser

* [Homepage](https://github.com/postmodern/ffi-http-parser#readme)
* [Issues](https://github.com/postmodern/ffi-http-parser/issues)
* [Documentation](http://rubydoc.info/gems/ffi-http-parser/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

Ruby FFI bindings to the [http-parser][1] library.

## Features

## Examples

    require 'ffi/http/parser'

    parser = FFI::HTTP::Parser.new do |parser|
      parser.on_message_begin do
        puts "message begin"
      end

      parser.on_message_complete do
        puts "message end"
      end

      parser.on_url do |data|
        puts "url: #{data}"
      end

      parser.on_header_field do |data|
        puts "field: #{data}"
      end

      parser.on_header_value do |data|
        puts "value: #{data}"
      end

      parser.on_body do |data|
        puts "body: #{data}"
      end
    end

## Requirements

* [http-parser](https://github.com/joyent/http-parser#readme) 1.0
* [ffi](https://github.com/ffi/ffi#readme) ~> 1.0

## Install

    $ gem install ffi-http-parser

## Copyright

Copyright (c) 2012 Hal Brodigan

See {file:LICENSE.txt} for details.

[1]: https://github.com/joyent/http-parser
