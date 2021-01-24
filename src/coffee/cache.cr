class Coffee::Cache
  property storage : Array(Entry)
  property option : Option::Cache
  property cleanAt : Time
  property rangeCapacity : Int32
  property mutex : Mutex

  def initialize(@storage : Array(Entry) = Array(Entry).new, taskCount : Int32 = 0_i32,
                 @option : Option::Cache = Option::Cache.new)
    @cleanAt = Time.local
    @rangeCapacity = Cache.maximum_range_capacity option.capacity, taskCount
    @mutex = Mutex.new :unchecked
  end

  def self.maximum_range_capacity(capacity : Int32, task_count : Int32)
    range_capacity = (capacity / task_count).round.to_i32 rescue nil
    range_capacity ||= 0_i32
    range_capacity = 1_i32 if range_capacity <= 0_i32

    range_capacity
  end

  def ip_range_full?(ip_range : IPAddress) : Bool
    @mutex.synchronize do
      count = storage.count { |item| ip_range.includes? item.superIpAddress }
      return true if rangeCapacity <= count

      false
    end
  end

  def high_priority_full?
    @mutex.synchronize do
      count = storage.count { |item| item.priority <= 1_i32 }
      return true if 2_i32 <= count

      false
    end
  end

  def full?
    option.capacity <= self.size
  end

  def half_full?
    (option.capacity / 2_i32 - self.size) <= 0_i32
  end

  def size
    @mutex.synchronize { storage.size }
  end

  def empty? : Bool
    @mutex.synchronize { storage.empty? }
  end

  def refresh_clean_at
    @mutex.synchronize { @cleanAt = Time.local }
  end

  def clean_expired?
    option.cleanInterval <= (Time.local - @mutex.synchronize { cleanAt })
  end

  def not_expired?
    !clean_expired?
  end

  def clear
    @mutex.synchronize { self.storage.clear }
  end

  def expired_clean
    return unless clean_expired?

    expired_clean!
  end

  def expired_clean!
    @mutex.synchronize do
      storage.each_with_index do |item, index|
        storage.delete_at index, 1_i32 if option.cleanInterval <= (Time.local - item.createdAt)
      end
    end

    refresh_clean_at
  end

  def <<(entry : Entry, ip_range : IPAddress)
    expired_clean

    if full? || ip_range_full? ip_range
      try_write_high_priority_entry entry, ip_range

      return
    end

    @mutex.synchronize { storage << entry }
  end

  def try_write_high_priority_entry(entry : Entry, ip_range : IPAddress)
    return if entry.priority > 1_i32

    @mutex.synchronize do
      storage.each_with_index do |item, index|
        next unless ip_range.includes? item.superIpAddress
        next unless item.priority > entry.priority

        storage.delete_at index, 1_i32
        storage << entry

        break
      end
    end
  end

  def to_ip_address(port : Int32) : Array(Socket::IPAddress)?
    return if storage.empty?

    @mutex.synchronize do
      _storage = storage.sort { |a, b| a.priority <=> b.priority }
      _storage.map { |item| Socket::IPAddress.new item.ipAddress.address, port }
    end
  end

  def to_ip_address : Array(Socket::IPAddress)?
    return if storage.empty?

    @mutex.synchronize { storage.map &.ipAddress }
  end
end
