# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bubble-wrap/all'

require 'sugarcube'
require 'sugarcube-animations'
require 'sugarcube-uikit'
require 'sugarcube-timer'
require 'sugarcube-numbers'

require 'motion-cocoapods'
require 'geomotion'
require 'motion-state-machine'

Motion::Project::App.setup do |app|

  # Use `rake config' to see complete project settings.

  app.name = 'ikazen'
  app.icons = %w(icon.png icon-72.png icon@2x.png)
  app.device_family = [:iphone]
  app.deployment_target = '7.0'
  app.interface_orientations = [:landscape_right]

  #app.pods do
  #  pod 'AGGeometryKit'
  #  pod 'GPUImage'
  #end

  app.vendor_project 'vendor/GPUImage/framework', :xcode, :target => 'GPUImage', :headers_dir => 'Source'
  app.vendor_project 'vendor/Warp', :static
  app.frameworks += %w{Foundation CoreFoundation OpenGLES QuartzCore CoreVideo CoreAnimation CoreMedia AVFoundation AudioToolbox ImageIO CoreGraphics UIKit SenTestingKit}

  app.codesign_certificate = '258J346JMA'
  app.provisioning_profile = './current.provisioning.mobileprovision'
end
