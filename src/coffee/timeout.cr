class Coffee::TimeOut
  include YAML::Serializable

  property connect : Int32
  property read : Int32
  property write : Int32

  def initialize(@connect : Int32 = 2_i32, @read : Int32 = 2_i32, @write : Int32 = 2_i32)
  end
end
