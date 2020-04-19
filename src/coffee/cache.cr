class Coffee::Cache
  property collects : Immutable::Vector(Entry)
  property capacity : Int32
  property cleanInterval : Time::Span
  property cleanAt : Time

  def initialize(@collects : Immutable::Vector(Entry) = Immutable::Vector(Entry).new, @capacity : Int32 = 5_i32,
                 @cleanInterval : Time::Span = 180_i32.seconds)
    @cleanAt = Time.local
  end

  def full?
    capacity <= size
  end

  def not_full?
    !full?
  end

  def size
    collects.size
  end

  def empty?
    collects.empty?
  end

  def refresh
    @cleanAt = Time.local
  end

  def clean_expired?
    (Time.local - cleanAt) > cleanInterval
  end

  def not_expired?
    !clean_expired?
  end

  def reset
    @collects = Immutable::Vector(Entry).new
  end

  def expires_clean
    return unless clean_expired?

    reset
    refresh
  end

  def <<(entry : Entry)
    expires_clean
    return if full?

    _collects = collects << entry
    self.collects = _collects

    refresh
  end

  def to_ip_address(port : Int32) : Array(Socket::IPAddress)?
    return if collects.empty?
    collects.map { |item| Socket::IPAddress.new item.ipAddress.address, port }
  end

  def to_ip_address : Array(Socket::IPAddress)?
    return if collects.empty?

    collects.map &.ipAddress
  end
end
