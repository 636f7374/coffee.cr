class Coffee::Config
  property options : Array(Serialization::Option)
  property tasks : Array(Task)
  property progressBar : Bool
  property writer : Writer?

  def initialize
    @options = [] of Serialization::Option
    @tasks = [] of Task
    @progressBar = true
    @writer = nil
  end

  def self.parse(args : Array(String))
    config = Config.new

    config.option_parse args
    config.unwrap_tasks

    config
  end

  def unwrap_tasks
    options.each do |option|
      next unless task = option.to_task writer

      tasks << task
    end

    options.clear
  end

  def unwrap_options(path : String)
    abort STDERR.puts "Not found / Invalid scanner Configuration file." unless File.file? path rescue nil

    content = File.read path rescue nil
    abort STDERR.puts "Unable to open the configuration file scanner." unless content

    payload = YAML.parse content rescue nil
    abort STDERR.puts "Unable to parse scanner configuration file." unless _payloads = payload.try &.as_a?

    _payloads.each do |item|
      option = Serialization::Option.from_yaml item.to_yaml rescue nil

      self.options << option if option
    end

    abort STDERR.puts "Scanner configuration is empty." if options.empty?
  end

  def option_parse(args : Array(String))
    OptionParser.parse args do |parser|
      parser.on("-i +", "--import +", "Import scanner Configuration file") do |value|
        unwrap_options value
      end

      parser.on("--disable-progress-bar", "Disable drawing Progress Bar") do |value|
        self.progressBar = false
      end

      parser.on("--output +", "-o +", "Use the same IO writer (Prevent out-of-order writing)") do |value|
        file = File.open value, "ab" rescue nil
        self.writer = Writer.new file if file
      end

      parser.missing_option do |flag|
        abort STDERR.puts String.build { |io| io << "Missing option" << " - " << flag }
      end

      parser.invalid_option do |flag|
        abort STDERR.puts String.build { |io| io << "Invalid option" << " - " << flag }
      end
    end
  end
end
