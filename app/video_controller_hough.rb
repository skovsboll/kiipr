class VideoControllerHough < UIViewController

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
    @video_camera >> @hough
    @video_camera >> @blend
    @line_generator >> @blend >> @output
  end


  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionBack)

    @blend = GPUImageAlphaBlendFilter.alloc.init

    @hough = GPUImageHoughTransformLineDetector.alloc.init
    @hough.lineDetectionThreshold = 0.4
    @hough.edgeThreshold = 0.8

    @line_generator = GPUImageLineGenerator.alloc.init
    @line_generator.setLineColorRed(1.0, green: 0.0, blue: 0.0)
    @line_generator.forceProcessingAtSize(Size(720, 480))
    @hough.setLinesDetectedBlock(lambda do |lines_ary, lines_detected, frame_time|
      @line_generator.renderLinesFromArray(lines_ary, count: lines_detected, frameTime: frame_time)
    end)

    @output = GPUImageView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view = @output
  end
end