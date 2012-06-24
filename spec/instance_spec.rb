require 'spec_helper'
require 'callback_examples'

require 'ffi/http/parser/instance'

describe Instance do
  describe "#initialize" do
    context "when initialized from a pointer" do
      it "should not call http_parser_init" do
        ptr = described_class.new.to_ptr

        FFI::HTTP::Parser.should_not_receive(:http_parser_init)

        described_class.new(ptr)
      end
    end

    context "when given a block" do
      it "should yield the new Instance" do
        expected = nil

        described_class.new { |parser| expected = parser }

        expected.should be_kind_of(described_class)
      end

      it "should allow changing the parser type" do
        parser = described_class.new do |parser|
          parser.type = :both
        end

        parser.type.should == :both
      end
    end
  end

  describe "#type" do
    it "should default to :request" do
      subject.type.should == :request
    end

    it "should convert the type to a Symbol" do
      subject[:type_flags] = TYPES[:both]

      subject.type.should == :both
    end

    it "should extract the type from the type_flags field" do
      subject[:type_flags] = ((0xff & ~0x3) | TYPES[:both])

      subject.type.should == :both
    end
  end

  describe "#type=" do
    it "should set the type" do
      subject.type = :both

      subject.type.should == :both
    end
  end

  describe "#<<" do
    it "should call http_parser_execute" do
      FFI::HTTP::Parser.should_receive(:http_parser_execute)

      subject << "GET / HTTP/1.1\r\n"
    end
  end

  describe "callbacks" do
    describe "on_message_begin" do
      include_examples "callback", {:on_message_begin => :on_path}

      subject do
        described_class.new do |parser|
          parser.on_message_begin { @begun = true }
        end
      end

      it "should trigger on a new request" do
        subject << "GET / HTTP/1.1"

        @begun.should be_true
      end
    end

    describe "on_path" do
      include_examples "callback", {:on_path => :on_query_string}

      let(:expected) { '/foo' }

      subject do
        described_class.new do |parser|
          parser.on_path { |data| @path = data }
        end
      end

      it "should pass the recognized path" do
        subject << "GET "

        @path.should be_nil

        subject << "#{expected} HTTP/1.1"

        @path.should == expected
      end
    end

    describe "on_query_string" do
      include_examples "callback", {:on_query_string => :on_fragment}

      let(:expected) { 'x=1&y=2' }

      subject do
        described_class.new do |parser|
          parser.on_query_string { |data| @query_string = data }
        end
      end

      it "should pass the recognized query_string" do
        subject << "GET /foo"

        @query_string.should be_nil

        subject << "?#{expected} HTTP/1.1"

        @query_string.should == expected
      end
    end

    describe "on_fragment" do
      include_examples "callback", {:on_fragment => :on_header_field}

      let(:expected) { 'bar' }

      subject do
        described_class.new do |parser|
          parser.on_fragment { |data| @fragment = data }
        end
      end

      it "should pass the recognized fragment" do
        subject << "GET /foo"

        @fragment.should be_nil

        subject << "##{expected} HTTP/1.1"

        @fragment.should == expected
      end
    end

    describe "on_url" do
      include_examples "callback", {:on_url => :on_header_field}

      let(:expected) { '/foo?q=1' }

      subject do
        described_class.new do |parser|
          parser.on_url { |data| @url = data }
        end
      end

      it "should pass the recognized url" do
        subject << "GET "

        @url.should be_nil

        subject << "#{expected} HTTP/1.1"

        @url.should == expected
      end
    end

    describe "on_header_field" do
      include_examples "callback", {:on_header_field => :on_header_value}

      let(:expected) { 'Host' }

      subject do
        described_class.new do |parser|
          parser.on_header_field { |data| @header_field = data }
        end
      end

      it "should pass the recognized header-name" do
        subject << "GET /foo HTTP/1.1\r\n"

        @header_field.should be_nil

        subject << "#{expected}: example.com\r\n"

        @header_field.should == expected
      end
    end

    describe "on_header_value" do
      include_examples "callback", {:on_header_value => :on_body}

      let(:expected) { 'example.com' }

      subject do
        described_class.new do |parser|
          parser.on_header_value { |data| @header_value = data }
        end
      end

      it "should pass the recognized header-value" do
        subject << "GET /foo HTTP/1.1\r\n"

        @header_value.should be_nil

        subject << "Host: #{expected}\r\n"

        @header_value.should == expected
      end
    end

    describe "on_headers_complete" do
      include_examples "callback", {:on_headers_complete => :on_body}

      subject do
        described_class.new do |parser|
          parser.on_headers_complete { @header_complete = true }
        end
      end

      it "should trigger on the last header" do
        subject << "GET / HTTP/1.1\r\n"
        subject << "Host: example.com\r\n"

        @header_complete.should be_nil

        subject << "\r\n"

        @header_complete.should be_true
      end

      context "when the callback returns :stop" do
        subject do
          described_class.new do |parser|
            parser.on_headers_complete { :stop }

            parser.on_body { |data| @body = data }
          end
        end

        it "should indicate there is no request body to parse" do
          subject << "GET / HTTP/1.1\r\n"
          subject << "Host: example.com\r\n"
          subject << "\r\n"
          subject << "Body"

          @body.should be_nil
        end
      end
    end

    describe "on_body" do
      include_examples "callback", {:on_body => :on_message_complete}

      let(:expected) { "Body" }

      subject do
        described_class.new do |parser|
          parser.on_body { |data| @body = data }
        end
      end

      it "should trigger on the body" do
        subject << "POST / HTTP/1.1\r\n"
        subject << "Transfer-Encoding: chunked\r\n"
        subject << "\r\n"

        @body.should be_nil

        subject << "#{"%x" % expected.length}\r\n"
        subject << expected

        @body.should == expected
      end
    end

    describe "on_message_complete" do
      subject do
        described_class.new do |parser|
          parser.on_message_complete { @message_complete = true }
        end
      end

      it "should trigger at the end of the message" do
        subject << "GET / HTTP/1.1\r\n"

        @message_complete.should be_nil

        subject << "Host: example.com\r\n\r\n"

        @message_complete.should be_true
      end
    end
  end

  describe "#reset!" do
    it "should call http_parser_init" do
      parser = described_class.new

      FFI::HTTP::Parser.should_receive(:http_parser_init)

      parser.reset!
    end

    it "should not change the type" do
      parser = described_class.new do |parser|
        parser.type = :both
      end

      parser.reset!

      parser.type.should == :both
    end
  end

  describe "#http_method" do
    let(:expected) { :POST }

    it "should set the http_method field" do
      subject << "#{expected} / HTTP/1.1\r\n"

      subject.http_method.should == expected
    end
  end

  describe "#http_major" do
    let(:expected) { 1 }

    context "when parsing requests" do
      it "should set the http_major field" do
        subject << "GET / HTTP/#{expected}."

        subject.http_major.should == expected
      end
    end

    context "when parsing responses" do
      subject do
        described_class.new do |parser|
          parser.type = :response
        end
      end

      it "should set the http_major field" do
        subject << "HTTP/#{expected}."

        subject.http_major.should == expected
      end
    end
  end

  describe "#http_minor" do
    let(:expected) { 2 }

    context "when parsing requests" do
      it "should set the http_minor field" do
        subject << "GET / HTTP/1.#{expected}\r\n"

        subject.http_minor.should == expected
      end
    end

    context "when parsing responses" do
      subject do
        described_class.new do |parser|
          parser.type = :response
        end
      end

      it "should set the http_major field" do
        subject << "HTTP/1.#{expected} "

        subject.http_minor.should == expected
      end
    end
  end

  describe "#http_version" do
    let(:expected) { '1.1' }

    before do
      subject << "GET / HTTP/#{expected}\r\n"
    end

    it "should combine #http_major and #http_minor" do
      subject.http_version.should == expected
    end
  end

  describe "#http_status" do
    context "when parsing requests" do
      before do
        subject << "GET / HTTP/1.1\r\n"
        subject << "Host: example.com\r\n"
        subject << "\r\n"
      end

      it "should not be set" do
        subject.http_status.should be_zero
      end
    end

    context "when parsing responses" do
      let(:expected) { 200 }

      subject do
        described_class.new do |parser|
          parser.type = :response
        end
      end

      before do
        subject << "HTTP/1.1 #{expected} OK\r\n"
        subject << "Location: http://example.com/\r\n"
        subject << "\r\n"
      end

      it "should set the http_status field" do
        subject.http_status.should == expected
      end
    end
  end

  describe "#upgrade?" do
    let(:upgrade) { 'WebSocket' }

    before do
      subject << "GET /demo HTTP/1.1\r\n"
      subject << "Upgrade: #{upgrade}\r\n"
      subject << "Connection: Upgrade\r\n"
      subject << "Host: example.com\r\n"
      subject << "Origin: http://example.com\r\n"
      subject << "WebSocket-Protocol: sample\r\n"
      subject << "\r\n"
    end

    it "should return true if the Upgrade header was set" do
      subject.upgrade?.should be_true
    end
  end
end
