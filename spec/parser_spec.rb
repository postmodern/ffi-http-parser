require 'spec_helper'
require 'ffi/http/parser'

describe FFI::HTTP::Parser do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).not_to be_empty
  end

  describe "new" do
    it "should create a new Instance object" do
      expect(subject.new).to be_kind_of(Instance)
    end

    context "when given a block" do
      it "should yield the new Instance object" do
        expected = nil

        subject.new { |parser| expected = parser }

        expect(expected).to be_kind_of(Instance)
      end
    end
  end
end
