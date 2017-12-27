#
#  Be sure to run `pod spec lint WCImagePicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                = "WCImagePicker"
  s.version             = "0.0.3"
  s.summary             = "简易好用的图片选择器(Simple and easy for image picker)"
  s.homepage            = "https://github.com/MeetDay/WCImagePicker"
  s.license             = "MIT"
  s.author              = { "wangchao" => "wang504615732@gmail.com" }
  # s.social_media_url  = "http://twitter.com/wangchao"
  s.platform            = :ios, "9.0"

  s.source              = { :git => "https://github.com/MeetDay/WCImagePicker.git", :tag => "0.0.3" }
  s.source_files        = "WCImagePicker/*.{h,m}"
  s.resource_bundles    = { "WCImagePicker" => "WCImagePicker/*.{xib,xcassets}" }
  s.frameworks          = "Photos", "PhotosUI"
  s.requires_arc        = true

end
