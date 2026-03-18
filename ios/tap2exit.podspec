Pod::Spec.new do |s|
  s.name             = 'tap2exit'
  s.version          = '1.0.0'
  s.summary          = 'Double-tap-to-exit functionality for Flutter apps.'
  s.description      = <<-DESC
A Flutter plugin providing double-tap-to-exit functionality with native Android Toast
support and safe no-op behavior on iOS.
                       DESC
  s.homepage         = 'https://github.com/jaberio/tap2exit'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your-email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'

  s.swift_version = '5.0'
end
