#
# Be sure to run `pod lib lint ChatBird.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChatBird'
  s.version          = '0.1.0'
  s.summary          = 'Provides a framework that connects the SendBird chat service to the Chatto UI'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        This pod provides the glue to connect the SendBird chat service with the Chatto UI.
                        DESC
  s.homepage         = 'https://github.com/velos/ChatBird'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'David Rajan' => 'david@velosmobile.com' }
  s.source           = { :git => 'https://github.com/velos/ChatBird.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform = :ios, '12.0'
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'ChatBird/Classes/**/*'
  s.resources = 'ChatBird/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
  
  # s.resource_bundles = {
  #   'ChatBird' => ['ChatBird/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SendBirdSDK'
  s.dependency 'Chatto'
  s.dependency 'ChattoAdditions'
  s.dependency 'Nuke'
end
