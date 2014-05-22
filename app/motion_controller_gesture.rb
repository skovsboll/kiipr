class MotionControllerGesture < UIViewController

  include SugarCube::CoreGraphics
  include Geometry

  def viewDidLoad
    super

    setup_collection
    create_filters
    chain_filters
  end

  def setup_collection
    size = [UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width]
    layout = UICollectionViewFlowLayout.new
    layout.itemSize = size
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal
    layout.minimumInteritemSpacing = 0
    @collection = UICollectionView.alloc.initWithFrame [[0,0], size], collectionViewLayout: layout
    self.view << @collection
    @items = Dir.glob(File.join(App.resources_path, 'photos/*.jpg')).map { |f| 'photos/' + File.basename(f) }
    @collection.registerClass(UICollectionViewCell, forCellWithReuseIdentifier: 'cellIdentifier')
    @collection.dataSource = self
    @collection.pagingEnabled = true
  end

  def collectionView(collectionView, numberOfItemsInSection: section)
    @items.length
  end

  def collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier('cellIdentifier', forIndexPath: indexPath)
    cell.subviews.each { |c| c.removeFromSuperview }
    cell.clipsToBounds = true
    image_view = UIImageView.alloc.initWithImage(@items[indexPath.item].uiimage)
    image_view.contentMode = UIViewContentModeScaleAspectFill
    cell << image_view
    cell
  end

  def viewDidAppear(animated)
    @video_camera.startCameraCapture
    puts 'video capture started'
    @collection.scrollToItemAtIndexPath([0, @items.length / 2].nsindexpath, atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally, animated: false)
  end

  def viewWillDisappear(animated)
    @video_camera.stop
  end


  def create_filters
    @video_camera = GPUImageVideoCamera.alloc.initWithSessionPreset(AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePositionFront)

    @output = GPUImageView.alloc.initWithFrame(UIScreen.mainScreen.bounds / 3)
    self.view << @output

    setup_motion_detection
  end


  # @return [void]
  def setup_motion_detection
    @motion_detector = GPUImageMotionDetector.alloc.init
    @motion = MovingAverage.new 16, 0.0
    @centroids = MovingAverage.new 16, 0.0

    @first_centroid_x = 0.0

    @motion_detector.setMotionDetectionBlock(lambda do |centroid, intensity, frame_time|
      @motion << intensity
      @centroids << centroid.x

      if @motion.average > motion_threshold
        puts 'M %0.1f    Ma %.1f   C %.1f   Ca %.1f\n' % [intensity*100, @motion.average*100, centroid.x*100, @centroids.average*100]
        if @first_centroid_x.nan? || @centroids.average.nan?
          @first_centroid_x = @centroids.average
        elsif @first_centroid_x - @centroids.average > displacement_threshold
          puts 'Moved LEFT'
          reset_averages
          scroll_collection :right
        elsif @centroids.average - @first_centroid_x > displacement_threshold
          puts 'Moved RIGHT'
          reset_averages
          scroll_collection :left
        end
      end
    end)
  end

  def scroll_collection(direction)
    current_item = @collection.indexPathsForVisibleItems.first.item
    max_items = @items.length

    new_index = case direction
                  when :left
                    if current_item > 0
                      [0, current_item - 1].nsindexpath
                    else
                      [0, current_item].nsindexpath
                    end
                  when :right
                    if current_item < max_items - 1
                      [0, current_item + 1].nsindexpath
                    else
                      [0, current_item].nsindexpath
                    end
                end

    @collection.scrollToItemAtIndexPath(new_index, atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally, animated: true)
  end


  def chain_filters
    @video_camera >> @motion_detector >> @output
  end

  def motion_threshold
    0.05
  end

  def displacement_threshold
    0.1
  end

  def reset_averages
    @centroids.reset Float::NAN
    @motion.reset 0.0
    @first_centroid_x = Float::NAN
  end


end