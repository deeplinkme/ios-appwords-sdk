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
  s.version          = "0.3.1"
  s.summary          = "Deeplink Marketplace SDK"
  s.description      = <<-DESC
                       Deeplink Marketplace SDK for exchanging clicks
                       DESC
  s.homepage         = "https://github.com/deeplinkme/ios-appwords-sdk"
  s.license          = 'MIT'
  s.author           = { "Amit Attias" => "amit@deeplink.me" }
  s.source           = { :git => "https://github.com/deeplinkme/ios-appwords-sdk.git", :tag => "V0.3" }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.social_media_url = 'https://twitter.com/deeplinkme'
  s.source_files = 'Pod/Classes/'
  s.resource_bundles = {
    'AppWords' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'AdSupport'
  s.vendored_frameworks = 'Pod/Classes/AppWordsSDK.framework'
end
