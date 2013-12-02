module Geometry
  class KMeans

    attr_reader :delta
    attr_reader :k

    def initialize(k = 4, delta = 0.00001)
      @k = k
      @delta = delta
    end


    # k++ seeding
    # @param [Array<Point>] points
    # @return [Array<Cluster>] clusters
    def seed(points)
      points_sample = points.sample(2)
      clusters = []
      clusters << Cluster.new(Line.new(points_sample[0], points_sample[1]))
      while clusters.length < @k

        # For each data point x, compute D(x),
        # the distance between x and the nearest center
        # that has already been chosen.
        probabilities = Hash[points.map do |point|
          shortest = Float::INFINITY
          clusters.each do |cluster|
            distance = cluster.distance_to(point)
            if distance < shortest
              shortest = distance
            end
          end
          [point, 1 + shortest ** 2]
        end]


        #Choose one new data point at random as a new center,
        # using a weighted probability distribution
        # where a point x is chosen
        # with probability proportional to D(x)2
        #pickup = Pickup.new(probabilities, uniq: true) { |v| v**2 }
        points_sample = [rand_from_weighted_hash(probabilities), rand_from_weighted_hash(probabilities)]
        clusters << Cluster.new(Line.new(points_sample[0], points_sample[1]))
      end
      clusters
    end

    def rand_from_weighted_hash hash
      total_weight = hash.inject(0) { |sum, (v, weight)| sum+weight }
      running_weight = 0
      n = rand * total_weight
      pick = nil
      hash.each do |v, weight|
        pick = v if n > running_weight && n <= running_weight+weight
        running_weight += weight
      end
      pick
    end

    # @return [Array<Cluster>] clusters found
    # @param [Array<Point>] points point cloud
    def find_clusters(points)

      fail "Not enough points. #{@k*2} required for k=#{@k} but only #{points.length} given." if points.length < @k * 2

      clusters = seed(points)

      iterations = 0
      while clusters.any?(&:moved?)

        #clusters += split_most_costly_cluster(clusters) if clusters.length < @k

        clusters.each &:clear_points

        assign_points(points, clusters)

        clusters.reject! { |c| c.number_of_points < 2 }

        clusters.each { |cluster| cluster.update_center delta }

        iterations += 1
      end

      puts "Converged after #{iterations} iterations"
      clusters
    end

    def assign_points(points, clusters)
      points.each do |point|
        shortest = Float::INFINITY
        cluster_found = nil
        clusters.each do |cluster|
          distance = cluster.distance_to(point)
          if distance < shortest
            cluster_found = cluster
            shortest = distance
          end
        end
        cluster_found.add_point point unless cluster_found.nil?
      end
    end


    # @return [Array<Cluster>] the clusters that were missing to reach k clusters
    # @param [Array<Clusters>] clusters
    def split_most_costly_cluster(clusters)
      costliest_cluster = clusters.select { |c| c.number_of_points >= 4 }.sort_by { |c| -c.cost }.first
      return [] unless costliest_cluster
      puts "costliest: #{costliest_cluster}"
      clusters.delete(costliest_cluster)
      seed(costliest_cluster.points)
    end

  end


  class Cluster

    attr_reader :center
    attr_reader :points

    def initialize(center)
      @center = center
      @points = []
      @moved = true
    end

    def add_point(point)
      @points << point
    end

    def update_center(delta = 0.001)
      @moved = false

      averages = {}
      [:x, :y].each do |dimension|
        averages[dimension] =
            @points.inject(0.0) { |sum, point| sum + point.send(dimension) } /
                @points.length unless @points.length == 0
      end

      # Find linear regression
      numerator = (0...@points.length).reduce(0) do |sum, i|
        sum + ((@points[i].x - averages[:x]) * (@points[i].y - averages[:y]))
      end

      denominator = @points.reduce(0) do |sum, p|
        sum + ((p.x - averages[:x]) ** 2)
      end

      slope = (numerator / denominator)
      intercept = averages[:y] - (slope * averages[:x])

      b_delta = 0
      b_delta = (intercept - @center.b).abs unless @center.b.nil?
      unless (slope - @center.a).abs + b_delta < delta
        @center = Geometry::HoughLine.new(slope, intercept)
        @moved = true
      end
    end

    def clear_points
      @points = []
      @moved = true
    end

    def distance_to(point)
      @center.distance_to point
    end

    def number_of_points
      @points.length
    end

    def to_s
      "#{@center.to_s}: #{number_of_points} points, cost: #{cost}"
    end

    def cost
      @points.inject(0) { |sum, point| sum + @center.distance_to(point) }
    end

    def moved?
      @moved
    end

  end
end
