require 'spec_helper'
require 'ffi/http/parser'

describe FFI::HTTP::Parser do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end

  describe "new" do
    it "should create a new Instance object" do
      subject.new.should be_kind_of(Instance)
    end

    context "when given a block" do
      it "should yield the new Instance object" do
        expected = nil

        subject.new { |parser| expected = parser }

        expected.should be_kind_of(Instance)
      end
    end
  end
end
