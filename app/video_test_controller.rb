class VideoTestController < UIViewController

  include SugarCube::CoreGraphics
  include Geometry



  def viewWillAppear
    super

    create_filters
    chain_filters
    @video_camera.startCameraCapture
  end



  def chain_filters
    source = @video_camera

    source >> @contrast

    @contrast >> @closing
    @closing >> @edge
    @edge >> @raw_output

    source >> @perspective_filter
    @perspective_filter >> @blend_filter
    @edge >> @blend_filter

    @blend_filter >> @output
  end



  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset1280x720, cameraPosition: AVCaptureDevicePositionBack)
    #@video_camera.outputImageOrientation = UIInterfaceOrientationPortrait

    @cluster_finder = Geometry::KMeans.new(4)

    @contrast = GPUImageContrastFilter.new
    #@contrast.forceProcessingAtSize(Size(WIDTH, HEIGHT))
    @contrast.contrast = 5.0

    @edge = GPUImageSobelEdgeDetectionFilter.new
    #@edge.forceProcessingAtSize(Size(WIDTH, HEIGHT))

    @closing = GPUImageClosingFilter.alloc.initWithRadius 4
    #@closing.forceProcessingAtSize(Size(WIDTH, HEIGHT))

    @threshold = GPUImageAdaptiveThresholdFilter.new
    @threshold.blurSize = 10.0

    @perspective_filter = GPUImageTransformFilter.new
    #@perspective_filter.forceProcessingAtSize(Size(WIDTH, HEIGHT))
    @perspective_filter.anchorTopLeft = false

    @blend_filter = GPUImageOverlayBlendFilter.new

    @output = GPUImageView.alloc.initWithFrame([[0, 0], [320, 480]])
    self.view = @output
  end

  def analyze_white(white, time)

    white = white.map { |p|
      cgp = p.CGPointValue
      Point.new(cgp.x, cgp.y)
    }

    puts "number of white pixels: #{white.length}. #{white}"

    return if white.length < 8

    lines = @cluster_finder.find_clusters(white).collect { |c| c.center }

    puts "found #{lines.length} borders"

    return if lines.length != 4

    x_range_1 = (-0.15 * WIDTH)..(1.15 * WIDTH)
    y_range_1 = (-0.15 * HEIGHT)..(1.15 * HEIGHT)

    corners = lines.combination(2).collect do |two_lines|
      two_lines[0].intersects(two_lines[1])
    end.compact
    # most often we'll have 6 corners from 4 lines, unless two or more are parallel
    puts "found #{corners.length} potential corners:"

    corners = corners.select { |c| x_range_1.cover?(c.x) && y_range_1.cover?(c.y) }
    puts "found #{corners.length} quad corners."

    return if corners.length != 4

    corners = ConvexHull.calculate_convex_hull(corners).reverse.rotate(3)
    puts "OK, the convex hull returns #{corners}"

    reverse_transform_image(corners) if corners.length == 4
  end


#@param quad [Array<Point>] points in quadrilateral
# @return [Void]
  def reverse_transform_image(quad)
    puts 'Reverse transforming image'
    puts quad

    agQuad = AGKit.quadFromPoints(quad)
    transform = AGKit.transform3DWithQuad(agQuad, fromBounds: CGRectMake(0.0, 0.0, WIDTH, HEIGHT))

    @perspective_filter.transform3D = transform
  end



#@return [Pointer]
# @param [Array<Line>] lines
  def to_lines_pointer(lines)
    floats = Pointer.new(:float, lines.length * 2)
    lines.compact.each_with_index do |p, i|
      floats[i * 2] = p.a
      floats[i * 2 + 1] = p.b
    end
    floats
  end


end