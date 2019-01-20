target 'ABFlow' do
  use_frameworks!

  pod 'AdFooter'
  pod 'SwiftIconFont'

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
