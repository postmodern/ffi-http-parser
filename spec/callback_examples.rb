shared_examples_for "callback" do |callback_pair|
  context "when it returns :error" do
    subject do
      callback, next_callback = callback_pair.to_a.first

      described_class.new do |parser|
        parser.send(callback) { |*args| :error }

        parser.send(next_callback) { @called = true }
      end
    end

    it "should stop the parser" do
      subject << "POST /path?q=1#fragment HTTP/1.1\r\n"
      subject << "Transfer-Encoding: chunked\r\n"
      subject << "\r\n"

      subject << "4\r\n"
      subject << "Body\r\n"

      subject << "0\r\n"

      @called.should_not be_true
    end
  end
end
