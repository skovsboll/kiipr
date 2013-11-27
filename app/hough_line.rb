module Geometry
# y = ax + b

  class HoughLine < Struct.new(:a, :b)

    # @param [HoughLine] other
    # @return [Point]
    def intersects (other)
      return nil if self.a == other.a

      x = (other.b - self.b) / (self.a - other.a)
      y = self.a * x + self.b

      Point.new(x, y)
    end

    def point1
     Point.new(0, self.b)
    end

    def point2
      Point.new(-self.a, 0)
    end

    def vertical?
      a.respond_to?(:infinite?) && a.infinite?
    end

    def horizontal?
      a == 0
    end

    # @param [Point] point
    # @return [Float] perpendicular distance
    def distance_to(point)
      return (b - point.y).abs if horizontal?
      return (b - point.x).abs if vertical?

      (point.y - self.a * point.x - self.b).abs / Math.sqrt(self.a ** 2 + 1)
    end

    def ==(other)
      a == other.a and b == other.b
    end

  end
end