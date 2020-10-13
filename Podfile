# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
        pod 'SwiftyJSON'

target 'Tangem Tap' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Tangem Tap
  pod 'AnyCodable-FlightSchool'
  pod 'BinanceChain', :git => 'https://bitbucket.org/tangem/swiftbinancechain.git', :tag => '0.0.7'
  pod 'HDWalletKit', :git => 'https://bitbucket.org/tangem/hdwallet.git', :tag => '0.3.8'
  pod 'TangemSdk', :git => 'git@bitbucket.org:tangem/card-sdk-swift.git', :tag => 'build-61'
  #pod 'TangemSdk', :path => '../card-sdk-swift'
  pod 'BlockchainSdk',:git => 'git@bitbucket.org:tangem/blockchain-sdk-swift.git', :tag => 'build-31'
  #pod 'BlockchainSdk', :path => '../blockchain-sdk-swift'
  pod 'web3swift', :git => 'https://bitbucket.org/tangem/web3swift.git', :tag => '2.2.3'
  pod 'Moya'
  pod 'EFQRCode'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'

  target 'Tangem TapTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Tangem TapUITests' do
    # Pods for testing
  end

end


pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
