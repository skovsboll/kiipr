describe Geometry::Line do

  it 'should calc distance to a point' do
    line = Geometry::Line.new(Geometry::Point.new(0,0), Geometry::Point.new(10,10))
    distance = line.distance_to(Geometry::Point.new(-5,5))
    (distance - Math.sqrt(5 ** 2 + 5 ** 2)).abs.should <= 0.001
  end

  it 'should calc distance to a point when horizontal' do
    line = Geometry::Line.new(Geometry::Point.new(0,5), Geometry::Point.new(10,5)) # a = 0
    distance = line.distance_to(Geometry::Point.new(-5,0))
    distance.should == 5.0
  end

  it 'should calc distance to a point when vertical' do
    line = Geometry::Line.new(Geometry::Point.new(10,5), Geometry::Point.new(10,10)) # a = infinity
    distance = line.distance_to(Geometry::Point.new(-5,0))
    distance.should == 15.0
  end

end

describe Geometry::HoughLine do

  it 'should calc distance to a point' do
    line = Geometry::HoughLine.new(1, 0)
    distance = line.distance_to(Geometry::Point.new(-5,5))
    (distance - Math.sqrt(5 ** 2 + 5 ** 2)).abs.should <= 0.001
  end

  it 'should calc distance to a point when horizontal' do
    line = Geometry::HoughLine.new(0, 5.0)
    distance = line.distance_to(Geometry::Point.new(-5,0))
    distance.should == 5.0
  end

  it 'should calc distance to a point when vertical' do
    line = Geometry::HoughLine.new(Float::INFINITY, 10.0) # a = infinity
    distance = line.distance_to(Geometry::Point.new(-5,0))
    distance.should == 15.0
  end

end