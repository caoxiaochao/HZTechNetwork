#
# Be sure to run `pod lib lint HZTechNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HZTechNetwork'
  s.version          = '0.1.0'
  s.summary          = '基于AFNetworking二次封装的网络请求框架，包含参数AES加密功能'
  s.homepage         = 'https://github.com/caoxiaochao/HZTechNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'caoxiaochao' => 'ccly080518@163.com' }
  s.source           = { :git => 'https://github.com/caoxiaochao/HZTechNetwork.git', :tag => s.version.to_s }
  s.source_files = 'HZTechNetwork/Classes/**/*'
  s.requires_arc  = true

  s.ios.deployment_target = '8.0'

  s.framework = "CFNetwork"
  s.dependency "AFNetworking", "~> 3.0"
end
