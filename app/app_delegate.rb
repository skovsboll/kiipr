class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = MotionController.new
    @window.makeKeyAndVisible

    true
  end
end
