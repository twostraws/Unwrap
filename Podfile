# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Unwrap' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # There isn't a lot we can do about warnings in thes pods, so silence them
  inhibit_all_warnings!

  # Pods for Unwrap
  pod 'SwiftEntryKit', '0.8.4'
  pod 'SDWebImage', '~> 4.0'
  pod 'MKRingProgressView', '~> 2.0'
  pod 'SourceEditor', :git => 'https://github.com/louisdh/source-editor.git', :branch => 'master'
  pod 'DZNEmptyDataSet', '~> 1.8'

  target 'UnwrapTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'UnwrapUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end

    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '4.1'
      end
    end
  end
end
