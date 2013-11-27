module Geometry
  class Line < Struct.new(:point1, :point2)

    def self.new_by_arrays(point1_coordinates, point2_coordinates)
      self.new(Point.new_by_array(point1_coordinates),
               Point.new_by_array(point2_coordinates))
    end

    def a
      dy = Float(point2.y - point1.y)
      dx = Float(point2.x - point1.x)

      return 0.0 if dy == 0

      dy / dx
    end

    def b
      return nil if vertical?

      # compute change in y between point1 and the origin
      dy = point1.x * a
      point1.y - dy
    end

    def x_intercept
      return nil if horizontal?

      # compute change in x between point1 and the origin
      dx = point1.y / a
      point1.x - dx
    end

    def parallel_to?(other)
      # Special handling for when one slope is inf and the other is -inf:
      return true if a.infinite? and other.a.infinite?

      a == other.a
    end

    def vertical?
      a.infinite?
    end

    def horizontal?
      a == 0
    end

    def intersect_x(other)
      if vertical? and other.vertical?
        if x_intercept == other.x_intercept
          return x_intercept
        else
          return nil
        end
      end

      return nil if horizontal? and other.horizontal?

      return x_intercept if vertical?
      return other.x_intercept if other.vertical?

      d_intercept = other.b - b
      d_slope = a - other.a

      # if d_intercept and d_slope are both 0, the result is NaN, which indicates
      # the lines are identical
      d_intercept / d_slope
    end

    def intersects(other)
      x = intersect_x( other )
      return nil if x.nil?

      Point.new(x, self.a * x)
    end

    def angle_to(other)
      # return absolute difference between angles to horizontal of self and other
      sa = Math::atan(a)
      oa = Math::atan(other.a)
      (sa-oa).abs
    end

    # @param [Point] point
    # @return [Float] perpendicular distance
    def distance_to(point)
      return (point1.y - point.y).abs if horizontal?
      return (point1.x - point.x).abs if vertical?

      (point.y - self.a * point.x - self.b).abs / Math.sqrt(self.a ** 2 + 1)
    end

    def ==(other)
      a == other.a and b == other.b
    end

    def to_s
      "x1=#{point1.x}, y1=#{point1.y}, x2=#{point2.x}, y2=#{point2.y}, a=#{a}, b=#{b}"
    end

  end
end