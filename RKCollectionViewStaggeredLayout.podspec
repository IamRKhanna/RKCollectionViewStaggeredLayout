Pod::Spec.new do |s|
  s.name             = 'RKCollectionViewStaggeredLayout'
  s.version          = '0.1.0'
  s.summary          = 'An implementation of staggered layout for UICollectionView that supports two and single column style on a per element basis.'
  s.homepage         = 'https://github.com/IamRKhanna/RKCollectionViewStaggeredLayout'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rahul Khanna' => 'khanna27rahul@gmail.com' }
  s.source           = { :git => 'https://github.com/IamRKhanna/RKCollectionViewStaggeredLayout.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/IamRKhanna'

  s.ios.deployment_target = '6.0'
  s.requires_arc = true
  s.source_files = '*.{h,m}'
  s.frameworks = 'UIKit'
end
