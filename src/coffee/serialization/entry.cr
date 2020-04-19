module Coffee::Serialization
  class Entry
    include JSON::Serializable

    property ipAddress : String
    property edge : String?
    property iata : String?
    property createdAt : String
    property timing : String

    def initialize(@ipAddress : String, @edge : String? = nil, @iata : String? = nil)
      @createdAt = String.new
      @timing = String.new
    end
  end
end
