class Coffee::Writer
  property io : IO
  property mutex : Mutex

  def initialize(@io : IO)
    @mutex = Mutex.new :unchecked
  end

  def close
    close! rescue nil
  end

  def close!
    io.close
  end

  def write(result : Entry)
    @mutex.synchronize do
      io << result.to_serialization
      io.puts
      io.flush
    end
  end

  def write(value : String)
    @mutex.synchronize do
      io << value
      io.puts
      io.flush
    end
  end

  def <<(value : String)
    @mutex.synchronize do
      io << value
      io.flush
    end
  end
end
