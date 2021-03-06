require "./src/coffee.cr"

case ARGV[0_i32]?
when "version", "--version", "-v"
  puts <<-EOF
Version:
  Coffee.cr - Cloudflare Edge Server Booster
  _Version_ - #{Coffee::VERSION} (2020.04.26)
EOF
when "help", "--help", "-h"
  puts <<-EOF
Usage: coffee [command] [--] [arguments]
Command:
  version, --version, -v  Display Version Information of Coffee.cr
  help, --help, -h        Show this Coffee: Cloudflare Edge Server Booster Help
Options:
  --disable-progress-bar  Disable drawing Progress Bar
  --import                Import scanner Configuration File
EOF
else
  config = Coffee::Config.parse ARGV, command_line: true
  abort if config.tasks.empty?

  scanner = Coffee::Scanner.new config.tasks, render: true
  scanner.render_pipe = STDOUT if config.progressBar

  scanner.perform
end
