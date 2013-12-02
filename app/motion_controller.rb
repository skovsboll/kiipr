class MotionController < UIViewController

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


  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionBack)

    @output = GPUImageView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    self.view = @output

    setup_motion_detection
    detect_shakes
  end


  # @return [void]
  def setup_motion_detection
    @motion_detector = GPUImageMotionDetector.alloc.init
    @motion = MovingAverage.new 8, 0.0

    @motion_detector.setMotionDetectionBlock(lambda do |centroid, intensity, frame_time|
      @motion << intensity

      if @motion.average > motion_threshold and @shakes.average < shake_threshold
        puts 'Motion detected!'
      end
    end)
  end

  def detect_shakes
    @accelerometer = UIAccelerometer.sharedAccelerometer
    @accelerometer.updateInterval = 0.1
    @accelerometer.delegate = self
    @shakes = MovingAverage.new(8, 1.0)
  end

  #@return [nil]
  def accelerometer(meter, didAccelerate: acc)
    acceleration = Math.sqrt(acc.x ** 2 + acc.y ** 2 + acc.z ** 2)
    normalized_acceleration = (acceleration - 1).abs
    @shakes << normalized_acceleration

    if @shakes.average < shake_threshold && @motion.average < motion_threshold
      puts 'Steady'
    else
      puts 'Shaky'
    end
  end


  def chain_filters
    @video_camera >> @motion_detector >> @output
  end


  def shake_threshold
    0.02
  end

  def motion_threshold
    0.05
  end


end