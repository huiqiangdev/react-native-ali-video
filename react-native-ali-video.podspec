require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-ali-video"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "8.0" }
  s.source       = { :git => "https://github.com/huiqiangdev/react-native-ali-video.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"
  s.static_framework = true
  s.resource_bundles = {
      'AliVideo' => ['assets/Player/*.png']
  }

  s.dependency "React-Core"
  s.dependency 'AliPlayerSDK_iOS', '5.4.4.1'
end
