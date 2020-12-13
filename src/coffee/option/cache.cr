module Coffee::Option
  class Cache
    property cleanInterval : Time::Span
    property capacity : Int32

    def initialize(@cleanInterval : Time::Span = 180_i32.seconds, @capacity : Int32 = 5_i32)
    end
  end
end
