class Coffee::Entry
  include JSON::Serializable

  property ipAddress : Socket::IPAddress
  property edge : Needle::Edge?
  property iata : Needle::IATA?
  property timing : Time::Span?
  property createdAt : Time

  def initialize(@ipAddress : Socket::IPAddress, @edge : Needle::Edge? = nil, @iata : Needle::IATA? = nil, @timing : Time::Span? = nil)
    @createdAt = Time.local
  end

  def to_serialization
    entry = Serialization::Entry.new ipAddress.address
    entry.edge = edge.to_s if edge
    entry.iata = iata.to_s if iata
    entry.createdAt = createdAt.to_rfc3339
    timing.try { |_timing| entry.timing = Elapsed.to_text _timing }

    entry.to_json
  end
end
