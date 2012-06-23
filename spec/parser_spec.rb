require 'spec_helper'
require 'ffi/http/parser'

describe FFI::HTTP::Parser do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
