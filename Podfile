# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'
source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'moneybook' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
   pod 'GRDB.swift'
   pod 'SnapKit'
   pod 'Charts'
   pod 'Firebase/Analytics'
   pod 'Firebase/Crashlytics'
   pod 'Firebase/Messaging'
   pod 'Google-Mobile-Ads-SDK'
   pod 'Localize-Swift'
   pod 'Toast-Swift'
   pod 'Firebase/RemoteConfig'
   pod 'Kingfisher'
   pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
   pod 'TPInAppReceipt'
end

target 'ShortcutWidgetExtension' do
  use_frameworks!
   pod 'GRDB.swift'
   pod 'Localize-Swift'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
