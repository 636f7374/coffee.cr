class Coffee::Cache
  property collects : Immutable::Vector(Entry)
  property capacity : Int32
  property cleanInterval : Time::Span
  property cleanAt : Time
  property rangeCapacity : Int32

  def initialize(@collects : Immutable::Vector(Entry) = Immutable::Vector(Entry).new, @capacity : Int32 = 5_i32,
                 @cleanInterval : Time::Span = 180_i32.seconds, taskCount : Int32 = 0_i32)
    @cleanAt = Time.local
    @rangeCapacity = Cache.maximum_range_capacity capacity, taskCount
  end

  def self.maximum_range_capacity(capacity : Int32, task_count : Int32)
    range_capacity = (capacity / task_count).round.to_i32
    range_capacity = 1_i32 if range_capacity <= 0_i32

    range_capacity
  end

  def ip_range_full?(ip_range : IPAddress) : Bool
    count = collects.count { |collect| ip_range.includes? collect.superIpAddress }
    return true if rangeCapacity <= count

    false
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

  def expired_clean
    return unless clean_expired?

    reset
    refresh
  end

  def <<(entry : Entry, ip_range : IPAddress)
    expired_clean
    return if ip_range_full? ip_range
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
