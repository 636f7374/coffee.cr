class Coffee::Scanner
  property tasks : Array(Task)
  property total : BigInt | Int32
  property render : Bool?

  def initialize(@tasks : Array(Task), @render : Bool? = false)
    @total = 0_i32

    flush_total
  end

  def render_pipe=(value : IO)
    @renderPipe = Writer.new value
  end

  def render_pipe=(value : Writer)
    @renderPipe = value
  end

  def render_pipe
    @renderPipe
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

  def flush_total
    tasks.each { |task| task.total.try { |_total| self.total += _total } }
  end

  private def render_progress
    return unless render
    return unless _render_pipe = render_pipe

    Render::Progress.mark _render_pipe
    all_finished = false

    loop do
      tasks.each do |task|
        Render::Progress.push _render_pipe, task
      end

      finished = true
      sleep 1_i32

      # Since each sleep is executed for one second, the result may be different before and after sleep.
      # So we added all_finished, which is used to determine whether it is over again (to prevent the progress bar rendering from malfunctioning).

      tasks.each { |task| break finished = false unless task.finished? }
      tasks.size.times { _render_pipe << "\e[A\e[K" } unless all_finished

      break tasks.each &.writer_close rescue nil if all_finished
      next all_finished = true if finished
    end

    self.finished = true
  end

  def perform
    channel = Channel(Bool).new

    spawn do
      render_progress
    end

    spawn do
      handle_task
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
