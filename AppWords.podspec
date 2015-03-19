#
# Be sure to run `pod lib lint AppWords.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AppWords"
  s.version          = "0.3"
  s.summary          = "Deeplink Marketplace SDK"
  s.description      = <<-DESC
                       Deeplink Marketplace SDK for exchanging clicks
                       DESC
  s.homepage         = "https://github.com/cellogic/deeplink-marketplace-sdk"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Amit Attias" => "amit@deeplink.me" }
  s.source           = { :git => "https://github.com/cellogic/deeplink-marketplace-sdk.git", :tag => "V0.3" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/'
  s.resource_bundles = {
    'AppWords' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AdSupport'
  s.vendored_frameworks = 'Pod/Classes/AppWordsSDK.framework'
  # s.dependency 'AFNetworking', '~> 2.3'
end
