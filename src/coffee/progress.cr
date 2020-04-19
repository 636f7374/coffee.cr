class Coffee::Progress
  property total : BigInt | Int32
  property position : BigInt
  property matched : BigInt
  property mismatch : BigInt
  property failure : BigInt
  property invalid : BigInt

  def initialize(@total : BigInt | Int32)
    @position = BigInt.new 0_i32
    @matched = BigInt.new 0_i32
    @mismatch = BigInt.new 0_i32
    @failure = BigInt.new 0_i32
    @invalid = BigInt.new 0_i32
  end

  def flush_total(size : BigInt | Int32)
    self.total = size
  end

  def added_position
    self.position += 1_i32
  end

  def added_matched
    self.matched += 1_i32
    added_position
  end

  def added_mismatch
    self.mismatch += 1_i32
    added_position
  end

  def added_failure
    self.failure += 1_i32
    added_position
  end

  def added_invalid
    self.invalid += 1_i32
    added_position
  end
end
