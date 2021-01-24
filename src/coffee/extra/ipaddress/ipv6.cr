module IPAddress
  class IPv6
    def self.parse_u128_address(u128 : BigInt, prefix = 128_i32) : IPAddress
      str = IN6FORMAT % (0_i32..7_i32).map { |i| UInt64.new (u128 >> (112_i32 - 16_i32 * i)) & 0xffff }

      IPAddress.new str + "/#{prefix}"
    end

    def each : Nil
      (network_u128..broadcast_u128).each do |item|
        yield self.class.parse_u128_address item, @prefix
      end
    end

    def includes?(other : IPv4)
      false
    end

    def includes?(*others : IPv4)
      false
    end

    def includes?(others : Array(IPv4))
      false
    end
  end
end
