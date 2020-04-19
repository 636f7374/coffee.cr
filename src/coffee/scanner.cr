class Coffee::Scanner
  property tasks : Array(Task)
  property total : BigInt | Int32
  property commandLine : Bool?

  def initialize(@tasks : Array(Task), @commandLine : Bool? = false)
    @total = 0_i32

    flush_total
  end

  def render_pipe=(value : IO)
    @renderPipe = Writer.new value
  end

  def render_pipe=(value : Writer)
    @renderPipe = value
  end

  def finished=(value : Bool)
    @finished = value
  end

  def finished?
    @finished
  end

  def cache=(value : Cache)
    tasks.each &.cache = value
    @cache = value
  end

  def cache
    @cache
  end

  def render_pipe
    @renderPipe
  end

  def flush_total
    tasks.each { |task| self.total += task.total }
  end

  private def render_progress
    return unless commandLine
    return unless _render_pipe = render_pipe
    Render::Progress.mark _render_pipe

    loop do
      tasks.each do |task|
        Render::Progress.push _render_pipe, task
      end

      finished = true
      sleep 1_i32

      tasks.each { |task| break finished = false unless task.finished? }
      tasks.size.times { _render_pipe << "\e[A\e[K" } unless finished

      break tasks.each &.writer_close if finished
    end

    self.finished = true
  end

  def perform
    channel = Channel(Bool).new

    spawn { handle_task }

    spawn do
      render_progress
    ensure
      channel.send true
    end

    channel.receive
  end

  private def handle_task
    until finished?
      channel = Channel(Bool).new

      tasks.each do |task|
        spawn do
          task.perform
        ensure
          channel.send true
        end
      end

      tasks.size.times { channel.receive }

      if cache.try &.full?
        sleep 30_i32.seconds
      end
    end
  end
end
