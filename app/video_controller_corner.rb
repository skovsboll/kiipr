class VideoControllerCorner < UIViewController

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
    @video_camera >> @contrast >> @closing >> @edge >> @corner

    @closing >> @blend >> @blend2 >> @output

    @crosshairGenerator >> @blend
    @crosshairGenerator2 >> @blend2
  end


  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionBack)

    @corner = GPUImageHarrisCornerDetectionFilter.new
    @corner.cornersDetectedBlock = lambda do |cornerArray, cornersDetected, frame_time|
      return if cornersDetected < 4
      points = to_point_array(cornersDetected, cornerArray)
      convex_points = ConvexHull.calculate_convex_hull(points)
      strong_angles_only = eliminate_weak_angles(convex_points)
      fail if convex_points.length > points.length
      @crosshairGenerator.setCrosshairColorRed(1.0, green: 0.0, blue: 0.0)
      @crosshairGenerator.renderCrosshairsFromArray(to_float_pointer(convex_points), count: convex_points.length, frameTime: frame_time)

      if strong_angles_only.length > 0
        @crosshairGenerator2.setCrosshairColorRed(0.0, green: 0.0, blue: 1.0)
        @crosshairGenerator2.renderCrosshairsFromArray(to_float_pointer(strong_angles_only), count: strong_angles_only.length, frameTime: frame_time)
      end

    end

    @crosshairGenerator = GPUImageCrosshairGenerator.new
    @crosshairGenerator.crosshairWidth = 30.0
    @crosshairGenerator.forceProcessingAtSize([640.0, 480.0])

    @crosshairGenerator2 = GPUImageCrosshairGenerator.new
    @crosshairGenerator2.crosshairWidth = 30.0
    @crosshairGenerator2.forceProcessingAtSize([640.0, 480.0])

    @contrast = GPUImageContrastFilter.new
    @contrast.contrast = 5.0

    @edge = GPUImageSobelEdgeDetectionFilter.new

    @closing = GPUImageClosingFilter.alloc.initWithRadius 4

    @blend = GPUImageAlphaBlendFilter.new
    @blend2 = GPUImageAlphaBlendFilter.new

    @output = GPUImageView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view = @output
  end

  #@return [Array<Point>]
  def to_point_array(count, float_ary)
    (0...count).collect do |i|
      x = float_ary[i * 2]
      y = float_ary[i * 2 + 1]
      Point.new x, y
    end
  end

  def to_float_pointer(points)
    floats = Pointer.new(:float, points.length * 2)
    points.compact.each_with_index do |p, i|
      floats[i * 2] = p.x
      floats[i * 2 + 1] = p.y
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