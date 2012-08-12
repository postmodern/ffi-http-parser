require 'spec_helper'
require 'ffi/http/parser/instance'

describe Instance::Callback do
  let(:parser) { Instance.new }

  describe "yielded arguments" do
    subject do
      described_class.new { |*arguments| @yielded_arguments = arguments }
    end

    before { subject.call(parser) }

    it "should not yield the parser" do
      @yielded_arguments.should be_empty
    end
  end

  context "when :return is thrown" do
    subject do
      described_class.new { throw :return, -1 }
    end

    it "should catch :return" do
      subject.call(parser).should == -1
    end
  end

  describe "return value" do
    subject { described_class.new { :do_stuff } }

    it "should return 0 by default" do
      subject.call(parser).should == 0
    end
  end
end
