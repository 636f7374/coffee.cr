class Coffee::Cache
  property storage : Immutable::Vector(Entry)
  property capacity : Int32
  property cleanInterval : Time::Span
  property cleanAt : Time
  property rangeCapacity : Int32

  def initialize(@storage : Immutable::Vector(Entry) = Immutable::Vector(Entry).new, @capacity : Int32 = 5_i32,
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
    count = storage.count { |collect| ip_range.includes? collect.superIpAddress }
    return true if rangeCapacity <= count

    false
  end

  def full?
    capacity <= size
  end

  def half_full?
    (capacity / 2_i32 - size) <= 0_i32
  end

  def size
    storage.size
  end

  def empty?
    storage.empty?
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
    @storage = Immutable::Vector(Entry).new
  end

  def expired_clean!
    reset
    refresh
  end

  def expired_clean
    return unless clean_expired?

    expired_clean!
  end

  def <<(entry : Entry, ip_range : IPAddress)
    expired_clean
    return if ip_range_full? ip_range
    return if full?

    _storage = storage << entry
    self.storage = _storage

    refresh
  end

  def to_ip_address(port : Int32) : Array(Socket::IPAddress)?
    return if storage.empty?

    storage.map { |item| Socket::IPAddress.new item.ipAddress.address, port }
  end

  def to_ip_address : Array(Socket::IPAddress)?
    return if storage.empty?

    storage.map &.ipAddress
  end
end
