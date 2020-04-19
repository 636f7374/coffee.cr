class Coffee::Task
  property ipRange : IPAddress
  property iatas : Array(Needle::IATA)
  property timeout : TimeOut
  property edges : Array(Needle::Edge)
  property progress : Progress
  property finished : Bool

  def initialize(@ipRange : IPAddress, @iatas : Array(Needle::IATA), @timeout : TimeOut = TimeOut.new)
    @edges = edges
    @progress = Progress.new ipRange.size
    @finished = false
  end

  def self.new(ip_range : String, needles : Array(Needle::IATA), timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range

    new _ip_range, writer, needles, timeout
  end

  def self.new(ip_range : String, needles : Array(Needle::Edge), timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range
    return unless _needles = needles.map &.to_iata?

    new _ip_range, writer, _needles, timeout
  end

  def self.new(ip_range : String, needle : Needle::IATA, timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range

    new _ip_range, writer, [needle], timeout
  end

  def self.new(ip_range : String, needle : Needle::Edge, timeout : TimeOut = TimeOut.new)
    return unless _ip_range = IPAddress.new ip_range
    _needles = needle.map &.to_iata?
    return if _needle.empty? || _needle.is_a? Array(Nil)

    new _ip_range, writer, _needles, timeout
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
    progress.flush_total ipRange.size
  end

  def total
    progress.total
  end

  def finished?
    finished
  end

  def perform(port : Int32 = 80_i32, method : String = "HEAD")
    task_elapsed = Time.monotonic

    ipRange.each do |ip_address|
      break if cache.try &.full? && cache.try &.not_expired?

      elapsed = Time.monotonic

      # Create Socket
      _ip_address = Socket::IPAddress.new ip_address.to_s, port

      begin
        socket = TCPSocket.new _ip_address, connect_timeout: timeout.connect
        socket.read_timeout = timeout.read
        socket.write_timeout = timeout.write
      rescue
        socket.try &.close rescue nil
        progress.added_failure

        next
      end

      # Write & Read Payload
      request = HTTP::Request.new method, "/"
      request.header_host = ip_address.to_s

      begin
        request.to_io socket
        response = HTTP::Client::Response.from_io socket
      rescue
        socket.close rescue nil
        progress.added_failure

        next
      end

      # Close Socket
      socket.close rescue nil

      # Check Match
      next progress.added_invalid unless value = response.headers["CF-RAY"]?
      id, delimiter, iata = value.rpartition "-"
      next progress.added_invalid unless _iata = Needle::IATA.parse? iata

      matched = false

      iatas.each do |needle|
        break matched = true if _iata == needle
      end

      next progress.added_mismatch unless matched
      _timing = Time.monotonic - elapsed

      # Write Entry
      entry = Entry.new _ip_address, _iata.to_edge?, _iata
      entry.timing = _timing

      writer.try &.write entry rescue nil
      cache.try &.<< entry

      progress.added_matched
    end

    self.timing = Time.monotonic - task_elapsed
    self.finished = true
  end

  def edges : Array(Needle::Edge)
    edges = [] of Needle::Edge

    iatas.each do |item|
      _edge = Needle::Edge.parse? item
      edges << _edge if _edge
    end

    edges
  end
end
