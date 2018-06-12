Pod::Spec.new do |s|
  s.name         = "FFmpegWrapper"
  s.version      = "1.2"
  s.summary      = "A lightweight Objective-C wrapper for some FFmpeg libav functions"
  s.homepage     = "https://github.com/Arlem/FFmpegWrapper"
  s.license      = 'LGPLv2.1'
  s.author       = { "Chris Ballinger" => "chris@openwatch.net" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/hearther/FFmpegWrapper.git"}
  s.source_files  = 'FFmpegWrapper/*.{h,m}'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.dependency 'ijkplayerPrecompiled'
#  s.dependency 'FFmpeg', '2.8.3'
end
