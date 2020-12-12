class Coffee::Task
  property ipRange : IPAddress
  property iatas : Array(Tuple(Needle::IATA, Int32))
  property timeout : TimeOut
  property edges : Array(Tuple(Needle::Edge, Int32))
  property progress : Progress?
  property finished : Bool

  def initialize(@ipRange : IPAddress, @iatas : Array(Tuple(Needle::IATA, Int32)), commandLine : Bool = false,
                 @timeout : TimeOut = TimeOut.new)
    @edges = edges
    @progress = Progress.new ipRange.size if commandLine
    @finished = false
  end

  def self.new(ip_range : String, needles : Array(Tuple(Needle::IATA, Int32)), timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range

    new _ip_range, writer, needles, timeout
  end

  def self.new(ip_range : String, needles : Array(Tuple(Needle::Edge, Int32)), timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range
    return unless _needles = needles.map { |needle| Tuple.new needle.first.to_iata?, needle.last }

    new _ip_range, writer, _needles, timeout
  end

  def self.new(ip_range : String, needle : Needle::IATA, timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range

    new _ip_range, writer, [Tuple.new needle, 1_i32], timeout
  end

  def self.new(ip_range : String, needle : Needle::Edge, timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range
    return unless _needle = needle.to_iata?

    new _ip_range, writer, [Tuple.new _needle, 1_i32], timeout
  end

  def timing=(value : Time::Span)
    @timing = value
  end

  def timing
    @timing
  end

  def writer=(value : Writer)
    @writer = value
  end

  def writer
    @writer
  end

  def cache=(value : Cache)
    @cache = value
  end

  def cache
    @cache
  end

  def writer_close
    writer_close! rescue nil
  end

  def writer_close!
    writer.try &.close!
  end

  def flush_edge
    self.edges = edges
  end

  def flush_total
    progress.try &.flush_total ipRange.size
  end

  def total
    progress.try &.total
  end

  def finished?
    finished
  end

  def perform(port : Int32 = 80_i32, method : String = "HEAD")
    return if finished? && progress
    task_elapsed = Time.monotonic

    # Set the minimum number of attempts, high priority IP is not always encountered often.
    cycle_times = 0_i32

    ipRange.each do |ip_address|
      # If caching is enabled, it will break if it expired
      timed_out = false

      cache.try do |_cache|
        timed_out = true if _cache.cleanInterval <= (Time.monotonic - task_elapsed)
      end

      break if timed_out

      # If the cache is full, break, If half full, sleep for 5 seconds
      if cache.try &.not_expired?
        if (cycle_times == 50_i32) || cache.try &.high_priority_full?
          break if cache.try &.full? || cache.try &.ip_range_full? ipRange
        end

        sleep 5_i32.seconds if cache.try &.half_full?
      end

      # To get Timing
      elapsed = Time.monotonic

      # Create Socket
      _ip_address = Socket::IPAddress.new ip_address.address, port

      begin
        socket = TCPSocket.new _ip_address, connect_timeout: timeout.connect
        socket.read_timeout = timeout.read
        socket.write_timeout = timeout.write
      rescue
        socket.try &.close rescue nil
        progress.try &.added_failure

        next cycle_times += 1_i32
      end

      # Write & Read Payload
      request = HTTP::Request.new method, "/"
      request.header_host = ip_address.address

      begin
        request.to_io socket
        response = HTTP::Client::Response.from_io socket
      rescue
        socket.close rescue nil
        progress.try &.added_failure

        next cycle_times += 1_i32
      end

      # Close Socket
      socket.close rescue nil

      # Check Match
      unless value = response.headers["CF-RAY"]?
        cycle_times += 1_i32
        next progress.try &.added_invalid
      end

      id, delimiter, iata = value.rpartition "-"

      unless _iata = Needle::IATA.parse? iata
        cycle_times += 1_i32
        next progress.try &.added_invalid
      end

      priority = 10_i32
      matched = false

      iatas.each do |needle|
        next unless _iata == needle.first

        priority = needle.last
        break matched = true
      end

      unless matched
        cycle_times += 1_i32
        next progress.try &.added_mismatch
      end

      # To get Timing
      _timing = Time.monotonic - elapsed

      # Write Entry
      entry = Entry.new _ip_address, ip_address, _iata.to_edge?, _iata, priority: priority
      entry.timing = _timing

      writer.try &.write entry rescue nil
      cache.try &.<< entry, ipRange

      progress.try &.added_matched
      cycle_times += 1_i32
    end

    self.timing = Time.monotonic - task_elapsed
    self.finished = true
  end

  def edges : Array(Tuple(Needle::Edge, Int32))
    edges = [] of Tuple(Needle::Edge, Int32)

    iatas.each do |item|
      _edge = Needle::Edge.parse? item.first
      _priority = item.last

      edges << Tuple.new _edge, _priority if _edge
    end

    edges
  end
end
