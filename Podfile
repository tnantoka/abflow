target 'ABFlow' do
  use_frameworks!

  pod 'AdFooter', git: 'https://gitlab.com/tnantoka/AdFooter.git'
  pod 'SwiftIconFont'
  pod 'SwiftLint'

  target 'ABFlowTests' do
    inherit! :search_paths
  end
end

plugin 'cocoapods-keys',
       project: 'ABFlow',
       keys: %w[
         adMobApplicationId
         adMobAdUnitId
       ]

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end
