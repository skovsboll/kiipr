class MotionControllerWithFsm < UIViewController

  include SugarCube::CoreGraphics
  include Geometry

  def viewDidLoad
    super

    create_filters
    chain_filters
  end

  def viewDidAppear(animated)
    @video_camera.startCameraCapture
    @fsm.start!
    puts 'video capture and state machine started'
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
    setup_state_machine
  end


  # @return [void]
  def setup_motion_detection
    @motion_detector = GPUImageMotionDetector.alloc.init
    @motion = MovingAverage.new 15, 0.0

    @motion_detector.setMotionDetectionBlock(lambda do |centroid, intensity, frame_time|
      @motion << intensity

      if @motion.average > motion_threshold and @shakes.average < shake_threshold
        EM.schedule_on_main { @fsm.event(:motion_detected) }
      end
    end)
  end

  def detect_shakes
    @accelerometer = UIAccelerometer.sharedAccelerometer
    @accelerometer.updateInterval = 0.1
    @accelerometer.delegate = self
    @shakes = MovingAverage.new(30, 1.0)
  end

  #@return [nil]
  def accelerometer(meter, didAccelerate: acc)
    acceleration = Math.sqrt(acc.x ** 2 + acc.y ** 2 + acc.z ** 2)
    normalized_acceleration = (acceleration - 1).abs
    @shakes << normalized_acceleration

    if @shakes.average < shake_threshold && @motion.average < motion_threshold
      EM.schedule_on_main { @fsm.event(:camera_steady) }
    end
  end


  def chain_filters
    @video_camera >> @motion_detector >> @output
    #@video_camera >> @output
  end


  def shake_threshold
    0.02
  end

  def motion_threshold
    0.05
  end


  # @return [void]
  def show_camera_animation
    @hidden_position = self.view.bounds.below.origin

    @camera_icon = UIImageView.alloc.initWithImage('images/camera_overlay'.uiimage)
    @camera_icon.frame = @hidden_position + CGSize.make(width: 60, height: 60)

    self.view << @camera_icon

    @camera_icon.move_to(self.view.bounds.center.left(30)) do
      2.seconds.later do
        @camera_icon.move_to @hidden_position do
          @camera_icon.removeFromSuperview
        end
      end
    end
  end


  def setup_state_machine
    @fsm = StateMachine::Base.new start_state: :waiting_for_new_paper, verbose: true

    @fsm.when :ready do |state|
      state.on_entry do
        puts 'FSM: ready'
        # pass
      end

      state.transition_to :capture_still, on: :camera_steady
      state.die on: :pause
    end

    @fsm.when :capture_still do |state|
      state.on_entry do
        puts 'FSM: capture!'
        #capture_still
        EM.schedule_on_main { @fsm.event(:still_captured) }

        #vibrate
        show_camera_animation
      end

      state.transition_to :capture_finished, on: :still_captured
      state.die on: :pause
    end

    @fsm.when :capture_finished do |state|
      state.on_entry do
        puts 'FSM: capture finished'
        reset_averages
      end

      state.transition_to :waiting_for_paper_to_be_removed, on: :motion_detected
      state.die on: :pause
    end

    @fsm.when :waiting_for_paper_to_be_removed do |state|
      state.on_entry do
        puts 'FSM: waiting for paper to be removed'
        reset_averages
      end

      state.transition_to :waiting_for_new_paper, on: :camera_steady
      state.die on: :pause
    end

    @fsm.when :waiting_for_new_paper do |state|
      state.on_entry do
        puts 'FSM: waiting for new paper'
        reset_averages
      end

      state.transition_to :ready, on: :motion_detected
      state.die on: :pause
    end
  end

  def reset_averages
    @shakes.reset 1.0
    @motion.reset 0.0
  end

end