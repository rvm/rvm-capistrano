require 'rspec/expectations'

RSpec::Matchers.define :abort_with_error do |message|
  match do |block|
    @block = block
    with_fake_stderr do
      @got_system_exit = false
      begin
        block.call
      rescue SystemExit
        @got_system_exit = true
        @stderr = $stderr.string
        message ? message === @stderr : true
      else
        false
      end
    end
  end

  description do
    "blahhh"
  end

  failure_message_for_should do |actual|
    if @got_system_exit
      "expected STDERR to match " + \
      ((message.is_a?(Regexp) ? "/%s/" : "'%s'") % message) + \
      " but got:\n#{@stderr}"
    else
      "expected #{@block} to raise SystemExit"
    end
  end

  # Fake STDERR and return a string written to it.
  def with_fake_stderr
    original_stderr = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = original_stderr
  end
end
