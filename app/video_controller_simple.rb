class VideoControllerSimple < UIViewController

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
    #@video_camera >> @edge >> @output
    @video_camera >> @contrast >> @closing >> @blend
    @video_camera >> @blend >> @output
  end


  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionBack)

    @contrast = GPUImageContrastFilter.new
    @contrast.contrast = 5.0

    @edge = GPUImageSobelEdgeDetectionFilter.new

    @closing = GPUImageClosingFilter.alloc.initWithRadius 4

    @blend = GPUImageOverlayBlendFilter.new

    @output = GPUImageView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view = @output
  end
end