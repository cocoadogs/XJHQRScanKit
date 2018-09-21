#
# Be sure to run `pod lib lint XJHQRScanKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XJHQRScanKit'
  s.version          = '0.1.1'
  s.summary          = 'A tool for QR and bar code scanning.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A tool for QR and bar code scanning.'

  s.homepage         = 'https://github.com/cocoadogs/XJHQRScanKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cocoadogs' => 'cocoadogs@163.com' }
  s.source           = { :git => 'https://github.com/cocoadogs/XJHQRScanKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.public_header_files = 'XJHQRScanKit/XJHQRScanKit.h'
#  s.source_files = 'XJHQRScanKit/**/*'
  s.source_files = 'XJHQRScanKit/XJHQRScanKit.h'
  s.resource = 'XJHQRScanKit/XJHQRScanKit.bundle'

  s.subspec 'XJHQRScanView' do |ss|
	  ss.dependency 'Masonry', '~> 1.1.0'
	  ss.ios.deployment_target = '8.0'
	  ss.source_files = 'XJHQRScanKit/XJHQRScanView.{h,m}','XJHQRScanKit/XJHQRScanViewParamsBuilder.{h,m}'
  end
  
  s.subspec 'XJHQRScanManager' do |ss|
	  ss.ios.deployment_target = '8.0'
	  ss.source_files = 'XJHQRScanKit/XJHQRScanManager.{h,m}', 'XJHQRScanKit/XJHQRScanManagerParamsBuilder.{h,m}'
  end
  
  # s.resource_bundles = {
  #   'XJHQRScanKit' => ['XJHQRScanKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'ReactiveObjC', '~> 3.1.0'
end
