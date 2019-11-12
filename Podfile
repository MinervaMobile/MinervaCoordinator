source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!

def minerva_pods
  pod 'IGListKit', :git => 'https://github.com/Instagram/IGListKit', :commit => '16df6cb220b4b5bfa545cbfd822119e5a56bc3e4'
  pod 'IQKeyboardManagerSwift'
  pod 'MBProgressHUD'
  pod 'RxSwift'
  pod 'SnapKit'
  pod 'SwiftLint'
  pod 'SwiftProtobuf'
  pod 'SwipeCellKit'
end

target 'Minerva' do
  platform :ios, '11.0'
  minerva_pods
end

target 'MinervaExample' do
  platform :ios, '11.0'
  minerva_pods
end

target 'MinervaTests' do
  platform :ios, '11.0'
  minerva_pods
end
