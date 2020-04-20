module IPAddress
  class IPv4
    def self.parse_u32_address(u32, prefix = 32_i32) : IPAddress
      octets = [] of Int32

      4_i32.times do
        octets.unshift u32.to_i! & 0xff
        u32 >>= 8_i32
      end

      address = octets.join '.'
      IPAddress.new "#{address}/#{prefix}"
    end

    def each : Nil
      (network_u32..broadcast_u32).each do |item|
        yield self.class.parse_u32_address item, @prefix
      end
    end

    def includes?(other : IPv6)
      false
    end

    def includes?(*others : IPv6)
      false
    end

    def includes?(others : Array(IPv6))
      false
    end
  end
end
