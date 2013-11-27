class VideoTestController < UIViewController

  include SugarCube::CoreGraphics
  include Geometry

  WIDTH = 120
  HEIGHT = 160

  def viewDidLoad
    super

    live = false

    if live
      @video_camera = GPUImageStillCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionBack)
      @video_camera.outputImageOrientation = UIInterfaceOrientationPortrait
    else
      url = '2013-04-27 13.52.25.mov'.resource_url
      @movie_player = GPUImageMovie.alloc.initWithURL(url)
      @movie_player.runBenchmark = false
      @movie_player.delegate = self
      @movie_player.playAtActualSpeed = true
    end

    #@rotater = GPUImageTransformFilter.new
    #@rotater.forceProcessingAtSize(Size(1920, 1920))
    #@rotater.affineTransform = CGAffineTransformMakeRotation(0.5.pi)

    @cluster_finder = Geometry::KMeans.new(4)

    @contrast = GPUImageContrastFilter.new
    @contrast.forceProcessingAtSize(Size(WIDTH, HEIGHT))
    @contrast.contrast = 5.0

    @edge = GPUImageSobelEdgeDetectionFilter.new
    @edge.forceProcessingAtSize(Size(WIDTH, HEIGHT))

    @closing = GPUImageClosingFilter.alloc.initWithRadius 4
    @closing.forceProcessingAtSize(Size(WIDTH, HEIGHT))

    @threshold = GPUImageAdaptiveThresholdFilter.new
    @threshold.blurSize = 10.0

    @perspective_filter = GPUImageTransformFilter.new
    @perspective_filter.forceProcessingAtSize(Size(WIDTH, HEIGHT))
    @perspective_filter.anchorTopLeft = false

    @raw_output = WhitePixelCounter.alloc.initWithImageSize([WIDTH, HEIGHT], resultsInBGRAFormat: false)

    @frame_no = 0
    @raw_output.whitePixelDetectedBlock = lambda do |white, time|
      analyze_white(white, time) if @frame_no % 200 == 0
      @frame_no += 1
    end

    @output = GPUImageView.alloc.initWithFrame([[0, 0], [320, 480]])
    self.view = @output

    # Filter chains

    source = if live
               @video_camera
             else
               @movie_player
             end

    source >> @contrast
    @contrast >> @closing
    @closing >> @edge
    @edge >> @raw_output

    @blend_filter = GPUImageOverlayBlendFilter.new

    source >> @perspective_filter
    @perspective_filter >> @blend_filter
    @edge >> @blend_filter
    @blend_filter >> @output

    if live
      @video_camera.startCameraCapture
    else
      @movie_player.startProcessing
    end
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


  def didCompletePlayingMovie
    @movie_player.startProcessing
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