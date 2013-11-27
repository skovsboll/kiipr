# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bubble-wrap/all'
require 'motion-ocr'
require 'sugarcube'
require 'motion-cocoapods'
require 'pickup'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ikazen'
  app.device_family = [:iphone]
  app.deployment_target = '5.1'
  app.interface_orientations = [:portrait]

  #app.pods do
  #  pod 'AGGeometryKit'
  #  pod 'GPUImage'
  #end

  app.vendor_project 'vendor/GPUImage/framework', :xcode, :target => 'GPUImage', :headers_dir => 'Source'
  app.vendor_project 'vendor/Warp', :static
  app.vendor_project 'vendor/AGKit', :xcode, :target => 'AGKit', :headers_dir => 'AGKit'

  app.frameworks += %w{Foundation CoreFoundation OpenGLES QuartzCore CoreVideo CoreAnimation CoreMedia AVFoundation AudioToolbox ImageIO CoreGraphics UIKit SenTestingKit}

  app.codesign_certificate = '258J346JMA'

end
