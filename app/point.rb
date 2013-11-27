module Geometry
  class Point < Struct.new(:x, :y)

    def self.new_by_array(array)
      fail unless array.is_a? Array
      self.new(array[0], array[1])
    end

    def ==(another_point)
      x === another_point.x && y === another_point.y
    end

    # @param [Point] other_point
    # @return [Float]
    def distance_to(other_point)
      Math.sqrt((other_point.x - x) ** 2 + (other_point.y - y) ** 2)
    end

    # @param [Line] line
    # @return [Float]
    def distance_to_line(line)
      line.distance_to self
    end

    def angle_from(other)
      Math.atan2(other.x - x, other.y - y)
    end

  end
end
