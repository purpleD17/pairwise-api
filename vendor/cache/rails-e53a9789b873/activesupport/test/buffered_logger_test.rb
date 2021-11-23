require 'abstract_unit'
require 'stringio'
require 'fileutils'
require 'tempfile'

class BufferedLoggerTest < Test::Unit::TestCase
  if defined?(Encoding)
    class IOWithAllergyToBinary < StringIO
      def write(data)
        if data.encoding == Encoding::BINARY
          raise "i'm not compatible with binary"
        else
          super
        end
      end
    end
  end

  def setup
    @message = "A debug message"
    @integer_message = 12345
    @output  = StringIO.new
    @logger  = ActiveSupport::BufferedLogger.new(@output)
  end

  def test_should_log_debugging_message_when_debugging
    @logger.level = Logger::DEBUG
    @logger.add(Logger::DEBUG, @message)
    assert @output.string.include?(@message)
  end

  def test_should_not_log_debug_messages_when_log_level_is_info
    @logger.level = Logger::INFO
    @logger.add(Logger::DEBUG, @message)
    assert ! @output.string.include?(@message)
  end

  def test_should_add_message_passed_as_block_when_using_add
    @logger.level = Logger::INFO
    @logger.add(Logger::INFO) {@message}
    assert @output.string.include?(@message)
  end

  def test_should_add_message_passed_as_block_when_using_shortcut
    @logger.level = Logger::INFO
    @logger.info {@message}
    assert @output.string.include?(@message)
  end

  def test_should_convert_message_to_string
    @logger.level = Logger::INFO
    @logger.info @integer_message
    assert @output.string.include?(@integer_message.to_s)
  end

  def test_should_convert_message_to_string_when_passed_in_block
    @logger.level = Logger::INFO
    @logger.info {@integer_message}
    assert @output.string.include?(@integer_message.to_s)
  end

  def test_should_not_evaluate_block_if_message_wont_be_logged
    @logger.level = Logger::INFO
    evaluated = false
    @logger.add(Logger::DEBUG) {evaluated = true}
    assert evaluated == false
  end

  def test_should_not_mutate_message
    message_copy = @message.dup
    @logger.info @message
    assert_equal message_copy, @message
  end


  [false, nil, 0].each do |disable|
    define_method "test_disabling_auto_flush_with_#{disable.inspect}_should_buffer_until_explicit_flush" do
      @logger.auto_flushing = disable

      4.times do
        @logger.info 'wait for it..'
        assert @output.string.empty?, "@output.string should be empty but it is #{@output.string}"
      end

      @logger.flush
      assert !@output.string.empty?, "@logger.send(:buffer).size.to_s should not be empty but it is empty"
    end

    define_method "test_disabling_auto_flush_with_#{disable.inspect}_should_flush_at_max_buffer_size_as_failsafe" do
      @logger.auto_flushing = disable
      assert_equal ActiveSupport::BufferedLogger::MAX_BUFFER_SIZE, @logger.auto_flushing

      (ActiveSupport::BufferedLogger::MAX_BUFFER_SIZE - 1).times do
        @logger.info 'wait for it..'
        assert @output.string.empty?, "@output.string should be empty but is #{@output.string}"
      end

      @logger.info 'there it is.'
      assert !@output.string.empty?, "@logger.send(:buffer).size.to_s should not be empty but it is empty"
    end
  end

  def test_should_know_if_its_loglevel_is_below_a_given_level
    ActiveSupport::BufferedLogger::Severity.constants.each do |level|
      @logger.level = ActiveSupport::BufferedLogger::Severity.const_get(level) - 1
      assert @logger.send("#{level.downcase}?"), "didn't know if it was #{level.downcase}? or below"
    end
  end

  def test_should_auto_flush_every_n_messages
    @logger.auto_flushing = 5

    4.times do
      @logger.info 'wait for it..'
      assert @output.string.empty?, "@output.string should be empty but it is #{@output.string}"
    end

    @logger.info 'there it is.'
    assert !@output.string.empty?, "@output.string should not be empty but it is empty"
  end

  def test_should_create_the_log_directory_if_it_doesnt_exist
    tmp_directory = File.join(File.dirname(__FILE__), "tmp")
    log_file = File.join(tmp_directory, "development.log")
    assert !File.exist?(tmp_directory)
    @logger  = ActiveSupport::BufferedLogger.new(log_file)
    assert File.exist?(tmp_directory)
  ensure
    FileUtils.rm_rf(tmp_directory)
  end

  def test_logger_should_maintain_separate_buffers_for_each_thread
    @logger.auto_flushing = false

    a = Thread.new do
      @logger.info("a"); Thread.pass;
      @logger.info("b"); Thread.pass;
      @logger.info("c"); @logger.flush
    end

    b = Thread.new do
      @logger.info("x"); Thread.pass;
      @logger.info("y"); Thread.pass;
      @logger.info("z"); @logger.flush
    end

    a.join
    b.join

    assert @output.string.include?("a\nb\nc\n")
    assert @output.string.include?("x\ny\nz\n")
  end

  def test_flush_should_remove_empty_buffers
    @logger.send :buffer
    @logger.expects :clear_buffer
    @logger.flush
  end

  if defined?(Encoding)
    def test_log_mixed_encodings
      prior_external = Encoding.default_external
      Encoding.default_external = Encoding::US_ASCII
      utf8_string = "some ütf-8"
      ascii_8bit_string = "some 8bit\xFF".force_encoding(Encoding::ASCII_8BIT)
      @logger.auto_flushing = false
      @logger.info(ascii_8bit_string)
      @logger.info(utf8_string)
      @logger.flush

      @output.set_encoding(Encoding::BINARY)
      utf8_string.force_encoding(Encoding::BINARY)
      assert(@output.string.include?(utf8_string))
      assert(@output.string.include?(ascii_8bit_string))
    ensure
      Encoding.default_external = prior_external
    end

    def test_log_mixed_encodings_with_underlying_io_object_with_encoding
      @output.set_encoding(Encoding::US_ASCII)
      @output.write('some ütf-8')
      # @output is now in a weird state where it will neither accept BINARY nur US_ASCII encodings
      @logger = ActiveSupport::BufferedLogger.new(@output)
      ascii_8bit_string = "some 8bit\xFF".force_encoding(Encoding::ASCII_8BIT)
      @logger.auto_flushing = false
      @logger.info(ascii_8bit_string)
      @logger.flush

      assert(@output.string.include?('some 8bit'))
    end

    def test_log_with_an_io_object_that_does_not_like_binary
      output = IOWithAllergyToBinary.new
      output.set_encoding(Encoding::UTF_8)
      logger = ActiveSupport::BufferedLogger.new(output)

      logger.auto_flushing = false
      logger.info("some ütf-8")
      logger.info("more ütf-8")
      logger.flush

      assert_equal Encoding::UTF_8, output.string.encoding
      assert_equal "some ütf-8\nmore ütf-8\n", output.string
    end

    def test_write_binary_data_to_existing_file
      t = Tempfile.new ['development', 'log']
      t.binmode
      t.write 'hi mom!'
      t.close

      logger = ActiveSupport::BufferedLogger.new(t.path)
      logger.level = Logger::DEBUG

      str = "\x80".force_encoding("ASCII-8BIT")

      logger.add Logger::DEBUG, str
      logger.flush
    ensure
      logger.close
      t.close true
    end

    def test_write_binary_data_create_file
      fname = File.join Dir.tmpdir, 'lol', 'rofl.log'
      logger = ActiveSupport::BufferedLogger.new(fname)
      logger.level = Logger::DEBUG

      str = "\x80".force_encoding("ASCII-8BIT")

      logger.add Logger::DEBUG, str
      logger.flush
    ensure
      logger.close
      File.unlink fname
    end
  end
end
