require 'spec_helper'
require 'ffi/http/parser/instance'

describe Instance::DataCallback do
  let(:parser) { Instance.new }
  let(:data)   { 'GET /' }
  let(:length) { data.length }

  let(:buffer) do
    FFI::Buffer.new(length).tap do |buffer|
      buffer.put_bytes(0,data)
    end
  end

  describe "yielded arguments" do
    subject do
      described_class.new { |data| @yielded_data = data }
    end

    before { subject.call(parser,buffer,length) }

    it "should yield the data" do
      @yielded_data.should == data
    end
  end

  context "when :return is thrown" do
    subject do
      described_class.new { |data| throw :return, -1 }
    end

    it "should catch :return" do
      subject.call(parser,buffer,length).should == -1
    end
  end

  describe "return value" do
    subject { described_class.new { |data| :do_stuff } }

    it "should return 0 by default" do
      subject.call(parser,buffer,length).should == 0
    end
  end
end
