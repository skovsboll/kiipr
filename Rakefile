# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bubble-wrap/all'

require 'sugarcube'
require 'sugarcube-animations'
require 'sugarcube-uikit'
require 'sugarcube-timer'
require 'sugarcube-numbers'
require 'sugarcube-foundation'

require 'motion-cocoapods'
require 'geomotion'
require 'motion-state-machine'

Motion::Project::App.setup do |app|

  app.name = 'ikazen'
  app.icons = %w(icon.png icon-72.png icon@2x.png)
  app.device_family = [:iphone]
  app.sdk_version = '7.0'
  app.deployment_target = '7.0'
  app.interface_orientations = [:landscape_right]

  app.vendor_project 'vendor/GPUImage/framework', :xcode, :target => 'GPUImage', :headers_dir => 'Source'
  app.vendor_project 'vendor/Warp', :static
  app.frameworks += %w{Foundation CoreFoundation OpenGLES QuartzCore CoreVideo CoreAnimation CoreMedia AVFoundation AudioToolbox ImageIO CoreGraphics UIKit SenTestingKit}

  app.provisioning_profile_pattern = /Vertica Madunivers/
  app.codesign_certificate = 'iPhone Developer'

  #app.codesign_certificate = '258J346JMA'
  #app.provisioning_profile = './current.provisioning.mobileprovision'
end
