#
# Be sure to run `pod lib lint LLUPNPServer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LLUPNPServer'
  s.version          = '0.1.0'
  s.summary          = 'UPNP投屏'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  简单实现iOS使用UPNP协议投屏功能
                       DESC

  s.homepage         = 'https://github.com/wilson7156/LLUPNPServer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '704110362@qq.com' => 'wilson' }
  s.source           = { :git => 'https://github.com/wilson7156/LLUPNPServer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LLUPNPServer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LLUPNPServer' => ['LLUPNPServer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'CocoaAsyncSocket', '~> 7.4.3'
   s.dependency 'XMLDictionary'
#   s.dependency 'GDataXML-HTML', '~> 1.1.0'
   s.dependency 'KissXML'
end
