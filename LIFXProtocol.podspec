#
#  Be sure to run `pod spec lint Protocol.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "LIFXProtocol"
  s.version      = "1.0.0"
  s.summary      = "Swift implemenation of the LIFX binary protocol."

  s.license      = { :type => 'Proprietary', :file => 'LICENSE' }
  s.homepage	 = "https://github.com/LIFX/protocol"
  s.author       = { "Alex Stonehouse" => "alexander@lifx.co" }
  s.source       = { :git => "https://github.com/LIFX/protocol.git", :branch => "swift" }

  # Version
  s.platform = :ios
  s.swift_version = "5.0"
  s.ios.deployment_target = "10.3"

  s.source_files  = "Sources/LIFXProtocol/**/*" 

end
