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
      parser.on_message_begin do |state|
        puts "message begin"
      end

      parser.on_message_complete do |state|
        puts "message end"
      end

      parser.on_url do |state,buffer,length|
        puts "url: #{buffer.get_bytes(0,length)}"
      end

      parser.on_header_field do |state,buffer,length|
        puts "field: #{buffer.get_bytes(0,length)}"
      end

      parser.on_header_value do |state,buffer,length|
        puts "value: #{buffer.get_bytes(0,length)}"
      end

      parser.on_body do |state,buffer,length|
        puts "body: #{buffer.get_bytes(0,length)}"
      end
    end

## Requirements

## Install

    $ gem install ffi-http-parser

## Copyright

Copyright (c) 2012 Hal Brodigan

See {file:LICENSE.txt} for details.

[1]: https://github.com/joyent/http-parser
