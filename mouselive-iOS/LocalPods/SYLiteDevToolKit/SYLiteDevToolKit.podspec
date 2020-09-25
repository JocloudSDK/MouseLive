#
# Be sure to run `pod lib lint Categories.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SYLiteDevToolKit"
  s.version          = "1.0.0"
  s.summary          = "SYLiteDevToolKit"
  s.description      = <<-DESC
        SYLiteDevToolKit
                       DESC
  s.homepage         = "https://www.sunclouds.com/"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "iPhuan"
  s.source           = { :git => "https://www.sunclouds.com/", :tag => s.version }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.frameworks       = "Foundation", "UIKit"


#*********************************SYCommon******************************#
    s.subspec 'SYCommon' do |common|
        common.source_files        = "SYCommon/**/*.{h,m}"
        common.public_header_files = "SYCommon/**/*.h"
        common.frameworks  = "AVFoundation", "CoreTelephony"

        common.dependency 'AFNetworking'

    end

#*********************************SYCategory******************************#
    s.subspec 'SYCategory' do |category|
        category.source_files        = "SYCategory/**/*.{h,m}"
        category.public_header_files = "SYCategory/**/*.h"
        category.resource            = "SYCategory/Images/*.png"

        category.dependency 'MBProgressHUD'
        category.dependency 'SYLiteDevToolKit/SYCommon'
    end


#*********************************SYTokenHelper******************************#
    s.subspec 'SYTokenHelper' do |token|
        token.source_files        = "SYTokenHelper/**/*.{h,m}"
        token.public_header_files = "SYTokenHelper/**/*.h"

        token.dependency 'SYLiteDevToolKit/SYCommon'
        token.dependency 'SYLiteDevToolKit/SYCategory'

    end
    
    
#*********************************SYUIComponent******************************#
    s.subspec 'SYUIComponent' do |ui|
        ui.source_files        = "SYUIComponent/**/*.{h,m}"
        ui.public_header_files = "SYUIComponent/**/*.h"

        ui.dependency 'Masonry'
        ui.dependency 'SYLiteDevToolKit/SYCommon'
        ui.dependency 'SYLiteDevToolKit/SYCategory'

    end



end
