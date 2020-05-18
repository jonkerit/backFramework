#
# Be sure to run `pod lib lint BJPlaybackUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'BJPlaybackUI'
    s.version          = '2.7.4'
    s.summary          = 'BJPlaybackUI SDK'
    s.description      = 'BJPlaybackUI SDK.'

    s.homepage         = 'https://github.com/oushizishu/BJPlaybackUI'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'oushizishu' => 'xinyapeng@baijiahulian.com' }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '9.0'
    
    s.source           = { :git => 'https://github.com/jonkerit/backFramework.git', :tag => s.version.to_s }
    s.frameworks = ['CoreGraphics', 'Foundation', 'MobileCoreServices', 'Photos', 'UIKit']
    
    s.requires_arc = true
    
    # use <"> but not <'> for #{s.name} and #{s.version}
    s.pod_target_xcconfig = {
        "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES", # requies both `user_target_xcconfig` and `pod_target_xcconfig`
        "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) BJPLAYBACKUI_NAME=#{s.name} BJPLAYBACKUI_VERSION=#{s.version}"
    }
    s.user_target_xcconfig = {
        "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES" # requies both `user_target_xcconfig` and `pod_target_xcconfig`
    }
    
    s.default_subspecs = ['static.source']
    
    ## 默认集成framework
    #s.subspec 'static' do |ss|
        ## framework
        #ss.ios.preserve_paths       = 'frameworks/BJPlaybackUI.framework'
       # ss.ios.source_files         = 'frameworks/BJPlaybackUI.framework/Versions/A/Headers/**/*.h'
       #ss.ios.public_header_files  = 'frameworks/BJPlaybackUI.framework/Versions/A/Headers/**/*.h'
        #ss.ios.resource             = 'frameworks/BJPlaybackUI.framework/Versions/A/Resources/BJPlaybackUI.bundle'
        #ss.ios.vendored_frameworks  = 'frameworks/BJPlaybackUI.framework'
   # end
    
    ## 集成源码
    s.subspec 'static.source' do |ss|
        ss.source_files = 'BJPlaybackUI/Classes/**/*'
        ss.resource_bundles = {
            'BJPlaybackUI' => ['BJPlaybackUI/**/*.xcassets']
        }
    end
    
    s.frameworks = ['Foundation', 'UIKit', 'CoreTelephony', 'CoreMedia', 'AVFoundation', 'AVKit', 'MediaPlayer']
    s.dependency "BJLiveBase",                        '~> 2.8.0'
    s.dependency "BJLiveBase/Base",                   '~> 2.8.0'
    s.dependency "BJLiveBase/HUD",                    '~> 2.8.0'
    s.dependency "BJLiveBase/Auth",                   '~> 2.8.0'
    s.dependency "BJLiveBase/Networking",             '~> 2.8.0'
    s.dependency "BJLiveBase/Networking+BaijiaYun",   '~> 2.8.0'
    s.dependency "BJLiveBase/WebImage/BJLWebImage",   '~> 2.8.0'

    s.dependency "BJVideoPlayerCore", "~> 2.7.4"
    
end
