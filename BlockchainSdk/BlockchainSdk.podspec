#
# Be sure to run `pod lib lint BlockchainSdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlockchainSdk'
  s.version          = '0.0.1'
  s.summary          = 'Use BlockchainSdk for Tangem wallet integration'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Use BlockchainSdk for Tangem wallet integration
                       DESC

  s.homepage         = 'https://github.com/TangemCash/tangem-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tangem AG' => '' }
  s.source           = { :git => 'https://github.com/TangemCash/tangem-sdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'BlockchainSdk/**/*'
  
  # s.resource_bundles = {
  #   'TangemSdk' => ['TangemSdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'BigInt'
  s.dependency 'SwiftyJSON'
  s.dependency 'Moya'
  s.dependency 'RxSwift'
  s.dependency 'Moya/RxSwift'
  s.dependency 'Sodium' 
  s.dependency 'SwiftCBOR'
  s.dependency 'stellar-ios-mac-sdk'
  s.dependency 'BinanceChain'
  s.dependency 'HDWalletKit'
  s.dependency 'web3swift'
  s.dependency 'TangemSdk'
  s.dependency 'AnyCodable-FlightSchool'
end