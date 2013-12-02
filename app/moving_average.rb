class MovingAverage

  #@param size [Integer]
  #@param initial_value [Numeric] initial value in all slots
  def initialize(size, initial_value)
    initial_value ||= 0.0
    @buffer = RingBuffer.new(size)
    @buffer.fill initial_value
  end

  #@return [Numeric]
  def average
    @buffer.reduce (:+) / @buffer.length
  end

  def reset(value)
    @buffer.fill value
  end

  def <<(value)
    @buffer.push value
  end

end