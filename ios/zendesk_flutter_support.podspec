#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zendesk_flutter_support.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zendesk_flutter_support'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ZendeskCoreSDK'
  s.dependency 'ZendeskSupportSDK'
  s.dependency 'ZendeskSupportProvidersSDK'
  s.dependency 'ZendeskChatSDK'
  s.dependency 'ZendeskChatProvidersSDK'
  s.dependency 'ZendeskAnswerBotSDK'
  s.dependency 'ZendeskAnswerBotProvidersSDK'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
