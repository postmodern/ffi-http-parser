shared_examples_for "callback" do |callback|
  context "when it returns :error" do
    subject do
      described_class.new do |parser|
        parser.send(callback) { |*args| :error }

        parser.on_message_complete { @message_complete = true }
      end
    end

    it "should stop the parser" do
      subject << "GET /path?q=1#fragment HTTP/1.1\r\n"
      subject << "Host: example.com\r\n"
      subject << "\r\n"
      subject << "Body"

      @message_complete.should be_nil
    end
  end
end
