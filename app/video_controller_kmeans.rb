class VideoControllerKMeans < UIViewController

  include SugarCube::CoreGraphics
  include Geometry

  def viewDidLoad
    super

    create_filters
    chain_filters
  end

  def viewDidAppear(animated)
    @video_camera.startCameraCapture
    puts 'video capture started'
  end

  def viewWillDisappear(animated)
    @video_camera.stop
  end


  def chain_filters
    @video_camera >> @contrast >> @closing >> @edge >> @raw_data_output

    @edge >> @blend >> @output

    @line_generator >> @blend
  end


  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionBack)

    frame = 0

    @raw_data_output = GPUImageRawDataOutput.alloc.initWithImageSize([45.0, 30.0], resultsInBGRAFormat: false)
    @raw_data_output.newFrameAvailableBlock = lambda do |frame_time|
      frame += 1

      return unless frame % 20 == 0

      white_pixels = find_white_pixels
      convex_points = ConvexHull.calculate_convex_hull(white_pixels)

      return if convex_points.length < 8

      clusters = @kMeans.find_clusters(convex_points)
      hough_lines = clusters.collect { |c| c.center }

      return if hough_lines.length < 4

      hough_lines = scale_hough_lines(hough_lines)
      lines_ary = to_lines_pointer(hough_lines)
      @line_generator.renderLinesFromArray(lines_ary, count: hough_lines.length, frameTime: frame_time)
    end

    @line_generator = GPUImageLineGenerator.alloc.init
    @line_generator.setLineColorRed(1.0, green: 0.0, blue: 0.0)
    @line_generator.forceProcessingAtSize(Size(720, 480))

    @contrast = GPUImageContrastFilter.new
    @contrast.contrast = 5.0
    @edge = GPUImageSobelEdgeDetectionFilter.new
    @closing = GPUImageClosingFilter.alloc.initWithRadius 4
    @blend = GPUImageAlphaBlendFilter.new

    @kMeans = KMeans.new

    @output = GPUImageView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view = @output
  end

  def scale_hough_lines(hough_lines)
    hough_lines.map do |l|
      HoughLine.new(l.a, 720 * l.b / 45.0)
    end
  end

  def find_white_pixels
    white_pixels = []
    (0..45).each { |x|
      (0..30).each { |y|
        cg_point = CGPoint.make(x: x, y: y)
        color = @raw_data_output.colorAtLocation(cg_point)
        white = color.red > 200
        white_pixels << Point.new(x, y) if white
      }
    }
    white_pixels
  end


  def to_lines_pointer(lines)
    floats = Pointer.new(:float, lines.length * 2)
    lines.compact.each_with_index do |p, i|
      floats[i * 2] = p.a
      floats[i * 2 + 1] = p.b
    end
    floats
  end


  # points must be ordered
  def eliminate_weak_angles(points)

    results = []
    points.each_with_index do |p, i|
      left = p
      middle = points[(i + 1) % points.length]
      right = points[(i + 2) % points.length]

      line1 = Line.new(left, middle)
      line2 = Line.new(middle, right)

      angle = line1.angle_to(line2)

      results << middle if angle.abs > 0.5.pi
    end

    results
  end


end