class Coffee::Config
  property ranges : Array(Serialization::Range)
  property tasks : Array(Task)
  property progressBar : Bool
  property writer : Writer?

  def initialize
    @ranges = [] of Serialization::Range
    @tasks = [] of Task
    @progressBar = true
    @writer = nil
  end

  def self.parse(args : Array(String), command_line : Bool = false)
    config = Config.new

    config.progressBar = false unless command_line
    config.option_parse args
    config.unwrap_tasks command_line

    config
  end

  def unwrap_tasks(command_line : Bool = false)
    ranges.each do |option|
      next unless task = option.to_task writer, command_line

      self.tasks << task
    end

    ranges.clear
  end

  def self.default_ranges(config : Config)
    option = Serialization::Range.new
    option.ipRange = "172.64.160.0/20"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "172.64.96.0/20"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "162.159.132.0/24"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "162.159.36.0/24"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "162.159.128.0/19"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "141.101.120.0/22"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "190.93.244.0/22"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option

    option = Serialization::Range.new
    option.ipRange = "198.41.214.0/23"
    option.needles = "asia"
    option.excludes.try &.needles = "sin"
    option.excludes.try &.type = "iata"
    option.type = "region"
    config.ranges << option
  end

  def self.default : Config
    config = new

    default_ranges config
    config.progressBar = false
    config.unwrap_tasks command_line: false

    config
  end

  def unwrap_ranges(path : String)
    abort STDERR.puts "Not found / Invalid scanner Configuration file." unless File.file? path rescue nil

    content = File.read path rescue nil
    abort STDERR.puts "Unable to open the configuration file scanner." unless content

    payload = YAML.parse content rescue nil
    abort STDERR.puts "Unable to parse scanner configuration file." unless _payloads = payload.try &.as_a?

    _payloads.each do |item|
      option = Serialization::Range.from_yaml item.to_yaml rescue nil

      self.ranges << option if option
    end

    abort STDERR.puts "Scanner configuration is empty." if ranges.empty?
  end

  def option_parse(args : Array(String))
    OptionParser.parse args do |parser|
      parser.on("-i +", "--import +", "Import scanner Configuration file") do |value|
        unwrap_ranges value
      end

      parser.on("--disable-progress-bar", "Disable drawing Progress Bar") do |value|
        self.progressBar = false
      end

      parser.on("--export +", "-o +", "Use the same IO writer (Prevent out-of-order writing)") do |value|
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
