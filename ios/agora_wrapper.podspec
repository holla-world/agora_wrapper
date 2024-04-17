#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint agora_wrapper.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'agora_wrapper'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = '**/*.{h,m,mm,swift}'
  s.dependency 'Flutter'
  s.dependency 'AgoraRtcEngine_iOS'
  s.dependency 'AgoraRtm_iOS', '1.5.1'
  s.dependency 'FURenderKit', '8.8.1'
  s.platform = :ios, '11.0'
  s.resource_bundles = {
      'faceunity_plugin' => ['Assets/**/*.{png,bundle,json}']
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
