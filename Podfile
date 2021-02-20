source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!

def minerva_pods
  pod 'IGListDiffKit', :git => 'https://github.com/Instagram/IGListKit'
  pod 'IGListKit', :git => 'https://github.com/Instagram/IGListKit'
  pod 'IQKeyboardManagerSwift'
  pod 'MBProgressHUD'
  pod 'RxSwift'
  pod 'RxRelay'
  pod 'SwiftLint'
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
