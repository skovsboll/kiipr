

describe Geometry::KMeans do

  it 'quickly converges' do

    points = []
    points << Geometry::Point.new(0.183333337306976, 0.0703125000000000)
    points << Geometry::Point.new(0.185416638851166, 0.0812499821186066)
    points << Geometry::Point.new(0.210416615009308, 0.170312464237213)
    points << Geometry::Point.new(0.285416603088379, 0.417187452316284)
    points << Geometry::Point.new(0.293749928474426, 0.442187428474426)
    points << Geometry::Point.new(0.306249976158142, 0.460937500000000)
    points << Geometry::Point.new(0.335416674613953, 0.470312476158142)
    points << Geometry::Point.new(0.556249856948853, 0.435937404632568)
    points << Geometry::Point.new(0.568749904632568, 0.428124904632568)
    points << Geometry::Point.new(0.556249856948853, 0.398437500000000)
    points << Geometry::Point.new(0.464583277702332, 0.182812452316284)
    points << Geometry::Point.new(0.406250000000000, 0.0562499910593033)
    points << Geometry::Point.new(0.399999976158142, 0.0453124940395355)
    points << Geometry::Point.new(0.381249904632568, 0.0296874940395355)
    points << Geometry::Point.new(0.218750000000000, 0.0578124970197678)
    points << Geometry::Point.new(0.189583301544189, 0.0671874880790710)

    k_means = Geometry::KMeans.new(4)
    clusters = k_means.find_clusters(points)

    clusters.length.should == 4

    clusters.each do |l|
      puts "#{l.center.a}, #{l.center.b}"
    end

    #2.596616744995120, -0.351093649864197
    #2.176380157470700, -0.818733930587769
    #-0.473840951919556, 0.161194026470184
    #-0.624997854232788, 0.783592224121094


  end

  it 'finds lines from linear points' do

    points = []

    points << Geometry::Point.new(1, 1)
    points << Geometry::Point.new(2, 2)
    points << Geometry::Point.new(3, 3)
    points << Geometry::Point.new(4, 4)
    points << Geometry::Point.new(5, 5)

    points << Geometry::Point.new(4, 0)
    points << Geometry::Point.new(5, 0.5)
    points << Geometry::Point.new(6, 1)
    points << Geometry::Point.new(7, 1.5)
    points << Geometry::Point.new(8, 2)

    k_means = Geometry::KMeans.new(2)
    clusters = k_means.find_clusters(points)

    clusters.each { |c| puts c.to_s }

    best_cost = clusters.reduce(0) { |sum, i| sum + i.cost }

    clusters.length.should == 2
    best_cost.should < 0.1

    lines = clusters.collect { |c| c.center }

    lines.should.include? Geometry::HoughLine.new(1, 0)
    lines.should.include? Geometry::HoughLine.new(0.5, -2)

  end


  it 'finds lines from randomly sorted linear points' do

    points = []

    points << Geometry::Point.new(1, 1)
    points << Geometry::Point.new(5, 5)
    points << Geometry::Point.new(4, 4)
    points << Geometry::Point.new(5, 0.5)

    points << Geometry::Point.new(8, 2)
    points << Geometry::Point.new(2, 2)
    points << Geometry::Point.new(6, 1)
    points << Geometry::Point.new(7, 1.5)
    points << Geometry::Point.new(4, 0)
    points << Geometry::Point.new(3, 3)

    k_means = Geometry::KMeans.new(2)
    clusters = k_means.find_clusters(points)
    best_cost = clusters.reduce(0) { |sum, i| sum + i.cost }

    clusters.each { |c| puts c.to_s }

    clusters.length.should == 2
    best_cost.should < 0.1

    lines = clusters.collect { |c| c.center }

    lines.should.include? Geometry::HoughLine.new(1, 0)
    lines.should.include? Geometry::HoughLine.new(0.5, -2)

  end

  it 'finds lines from noisy linear points' do

    points = []

    points << Geometry::Point.new(1, 1.1)
    points << Geometry::Point.new(1.9, 2)
    points << Geometry::Point.new(3, 3)
    points << Geometry::Point.new(4, 4)
    points << Geometry::Point.new(5.1, 4.9)

    points << Geometry::Point.new(3.9, 0.1)
    points << Geometry::Point.new(5, 0.4)
    points << Geometry::Point.new(6.2, 1)
    points << Geometry::Point.new(6.8, 1.6)
    points << Geometry::Point.new(7.9, 1.8)

    k_means = Geometry::KMeans.new(2)
    clusters =k_means.find_clusters(points)
    best_cost = clusters.reduce(0) { |sum, i| sum + i.cost }

    clusters.each { |c| puts c.to_s }

    clusters.length.should == 2
    best_cost.should < 0.75

    lines = clusters.collect { |c| c.center }

    lines.any?{ |l| (0.75...1.25).cover?(l.a) and (-0.25...0.25).cover?(l.b) }.should == true
    lines.any?{ |l| (0.25...0.75).cover?(l.a) and (-2.45...-1.75).cover?(l.b) }.should == true

  end

  it 'finds 4 lines in a quad' do

    points = [Geometry::Point.new(2.0, 68.0 ),
              Geometry::Point.new(2.0, 84.0 ),
              Geometry::Point.new(4.0, 43.0 ),
              Geometry::Point.new(5.0, 43.0 ),
              Geometry::Point.new(10.0, 83.0 ),
              Geometry::Point.new(11.0, 90.0 ),
              Geometry::Point.new(12.0, 42.0 ),
              Geometry::Point.new(12.0, 90.0 ),
              Geometry::Point.new(13.0, 42.0 ),
              Geometry::Point.new(18.0, 82.0 ),
              Geometry::Point.new(19.0, 89.0 ),
              Geometry::Point.new(20.0, 57.0 ),
              Geometry::Point.new(20.0, 89.0 ),
              Geometry::Point.new(20.0, 115.0),
              Geometry::Point.new(21.0, 57.0 ),
              Geometry::Point.new(21.0, 115.0),
              Geometry::Point.new(22.0, 115.0),
              Geometry::Point.new(23.0, 114.0),
              Geometry::Point.new(24.0, 114.0),
              Geometry::Point.new(25.0, 114.0),
              Geometry::Point.new(26.0, 81.0 ),
              Geometry::Point.new(26.0, 113.0),
              Geometry::Point.new(26.0, 114.0),
              Geometry::Point.new(27.0, 88.0 ),
              Geometry::Point.new(27.0, 113.0),
              Geometry::Point.new(27.0, 114.0),
              Geometry::Point.new(28.0, 56.0 ),
              Geometry::Point.new(28.0, 88.0 ),
              Geometry::Point.new(28.0, 113.0),
              Geometry::Point.new(29.0, 56.0 ),
              Geometry::Point.new(29.0, 113.0),
              Geometry::Point.new(30.0, 113.0),
              Geometry::Point.new(31.0, 113.0),
              Geometry::Point.new(32.0, 113.0),
              Geometry::Point.new(34.0, 80.0 ),
              Geometry::Point.new(34.0, 112.0),
              Geometry::Point.new(35.0, 112.0),
              Geometry::Point.new(36.0, 55.0 ),
              Geometry::Point.new(36.0, 112.0),
              Geometry::Point.new(37.0, 39.0 ),
              Geometry::Point.new(37.0, 55.0 ),
              Geometry::Point.new(37.0, 112.0),
              Geometry::Point.new(38.0, 112.0),
              Geometry::Point.new(41.0, 79.0 ),
              Geometry::Point.new(42.0, 79.0 ),
              Geometry::Point.new(44.0, 38.0 ),
              Geometry::Point.new(45.0, 38.0 ),
              Geometry::Point.new(45.0, 54.0 ),
              Geometry::Point.new(49.0, 78.0 ),
              Geometry::Point.new(50.0, 78.0 ),
              Geometry::Point.new(57.0, 77.0 ),
              Geometry::Point.new(58.0, 77.0 ),
              Geometry::Point.new(65.0, 76.0 ),
              Geometry::Point.new(66.0, 76.0 ),
              Geometry::Point.new(67.0, 28.0 ),
              Geometry::Point.new(73.0, 75.0 ),
              Geometry::Point.new(74.0, 75.0 ),
              Geometry::Point.new(75.0, 82.0 ),
              Geometry::Point.new(76.0, 27.0 ),
              Geometry::Point.new(76.0, 28.0 ),
              Geometry::Point.new(76.0, 82.0 ),
              Geometry::Point.new(77.0, 27.0 ),
              Geometry::Point.new(77.0, 28.0 ),
              Geometry::Point.new(77.0, 29.0 ),
              Geometry::Point.new(78.0, 27.0 ),
              Geometry::Point.new(78.0, 28.0 ),
              Geometry::Point.new(79.0, 27.0 ),
              Geometry::Point.new(79.0, 28.0 ),
              Geometry::Point.new(80.0, 27.0 ),
              Geometry::Point.new(80.0, 28.0 ),
              Geometry::Point.new(81.0, 27.0 ),
              Geometry::Point.new(81.0, 28.0 ),
              Geometry::Point.new(82.0, 27.0 ),
              Geometry::Point.new(82.0, 28.0 ),
              Geometry::Point.new(83.0, 27.0 ),
              Geometry::Point.new(83.0, 28.0 ),
              Geometry::Point.new(84.0, 27.0 ),
              Geometry::Point.new(84.0, 28.0 ),
              Geometry::Point.new(85.0, 27.0 ),
              Geometry::Point.new(85.0, 28.0 ),
              Geometry::Point.new(86.0, 27.0 ),
              Geometry::Point.new(86.0, 28.0 ),
              Geometry::Point.new(87.0, 28.0 ),
              Geometry::Point.new(87.0, 29.0 ),
              Geometry::Point.new(88.0, 28.0 ),
              Geometry::Point.new(88.0, 29.0 ),
              Geometry::Point.new(89.0, 28.0 ),
              Geometry::Point.new(89.0, 29.0 ),
              Geometry::Point.new(89.0, 73.0 ),
              Geometry::Point.new(89.0, 89.0 ),
              Geometry::Point.new(90.0, 28.0 ),
              Geometry::Point.new(90.0, 57.0 ),
              Geometry::Point.new(90.0, 89.0 ),
              Geometry::Point.new(91.0, 28.0 ),
              Geometry::Point.new(91.0, 57.0 ),
              Geometry::Point.new(92.0, 28.0 ),
              Geometry::Point.new(93.0, 28.0 ),
              Geometry::Point.new(94.0, 28.0 ),
              Geometry::Point.new(94.0, 29.0 ),
              Geometry::Point.new(95.0, 27.0 ),
              Geometry::Point.new(95.0, 28.0 ),
              Geometry::Point.new(95.0, 29.0 ),
              Geometry::Point.new(96.0, 27.0 ),
              Geometry::Point.new(96.0, 28.0 ),
              Geometry::Point.new(96.0, 29.0 ),
              Geometry::Point.new(97.0, 27.0 ),
              Geometry::Point.new(97.0, 28.0 ),
              Geometry::Point.new(97.0, 29.0 ),
              Geometry::Point.new(97.0, 72.0 ),
              Geometry::Point.new(97.0, 88.0 ),
              Geometry::Point.new(98.0, 27.0 ),
              Geometry::Point.new(98.0, 28.0 ),
              Geometry::Point.new(98.0, 29.0 ),
              Geometry::Point.new(98.0, 56.0 ),
              Geometry::Point.new(98.0, 72.0 ),
              Geometry::Point.new(98.0, 88.0 ),
              Geometry::Point.new(99.0, 27.0 ),
              Geometry::Point.new(99.0, 28.0 ),
              Geometry::Point.new(99.0, 29.0 ),
              Geometry::Point.new(99.0, 30.0 ),
              Geometry::Point.new(99.0, 56.0 ),
              Geometry::Point.new(100.0, 27.0 ),
              Geometry::Point.new(100.0, 28.0 ),
              Geometry::Point.new(100.0, 29.0 ),
              Geometry::Point.new(100.0, 30.0 ),
              Geometry::Point.new(100.0, 47.0 ),
              Geometry::Point.new(101.0, 27.0 ),
              Geometry::Point.new(101.0, 28.0 ),
              Geometry::Point.new(101.0, 29.0 ),
              Geometry::Point.new(101.0, 30.0 ),
              Geometry::Point.new(102.0, 27.0 ),
              Geometry::Point.new(102.0, 28.0 ),
              Geometry::Point.new(102.0, 29.0 ),
              Geometry::Point.new(102.0, 30.0 ),
              Geometry::Point.new(102.0, 124.0),
              Geometry::Point.new(103.0, 27.0 ),
              Geometry::Point.new(103.0, 28.0 ),
              Geometry::Point.new(103.0, 29.0 ),
              Geometry::Point.new(103.0, 30.0 ),
              Geometry::Point.new(103.0, 124.0),
              Geometry::Point.new(104.0, 27.0 ),
              Geometry::Point.new(104.0, 28.0 ),
              Geometry::Point.new(104.0, 29.0 ),
              Geometry::Point.new(104.0, 124.0),
              Geometry::Point.new(105.0, 27.0 ),
              Geometry::Point.new(105.0, 28.0 ),
              Geometry::Point.new(105.0, 29.0 ),
              Geometry::Point.new(105.0, 124.0),
              Geometry::Point.new(106.0, 27.0 ),
              Geometry::Point.new(106.0, 28.0 ),
              Geometry::Point.new(106.0, 29.0 ),
              Geometry::Point.new(106.0, 55.0 ),
              Geometry::Point.new(106.0, 71.0 ),
              Geometry::Point.new(106.0, 87.0 ),
              Geometry::Point.new(106.0, 124.0),
              Geometry::Point.new(107.0, 27.0 ),
              Geometry::Point.new(107.0, 28.0 ),
              Geometry::Point.new(107.0, 29.0 ),
              Geometry::Point.new(107.0, 55.0 ),
              Geometry::Point.new(108.0, 27.0 ),
              Geometry::Point.new(108.0, 28.0 ),
              Geometry::Point.new(109.0, 27.0 ),
              Geometry::Point.new(109.0, 28.0 ),
              Geometry::Point.new(110.0, 28.0 ),
              Geometry::Point.new(110.0, 123.0),
              Geometry::Point.new(111.0, 28.0 ),
              Geometry::Point.new(112.0, 28.0 ),
              Geometry::Point.new(113.0, 28.0 ),
              Geometry::Point.new(114.0, 54.0 ),
              Geometry::Point.new(114.0, 70.0 ),
              Geometry::Point.new(114.0, 86.0 ),
              Geometry::Point.new(115.0, 54.0 ),
              Geometry::Point.new(116.0, 45.0)]

    k_means = Geometry::KMeans.new(4)

    clusters =  k_means.find_clusters(points)
    best_cost = clusters.reduce(0) { |sum, i| sum + i.cost }

    clusters.each { |c| puts c.to_s }

    clusters.length.should == 4
    best_cost.should < 0.75

    lines = clusters.collect { |c| c.center }

  end

end