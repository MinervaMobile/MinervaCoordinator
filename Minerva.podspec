Pod::Spec.new do |s|
  s.name = "Minerva"
  s.version = "2.11.4"
  s.license = { :type => 'MIT', :file => 'LICENSE' }

  s.summary = "A Swift MVVM + Coordinator Framework"
  s.homepage = "https://github.com/OptimizeFitness/Minerva"
  s.author = { "Joe Laws" => "joe@optimize.fitness" }

  s.source = { :git => "https://github.com/OptimizeFitness/Minerva.git", :tag => s.version }

  s.default_subspecs = 'Cells', 'Convenience', 'Coordination', 'List', 'Swipe'

  s.requires_arc = true
  s.swift_versions = '5.1'

  s.ios.deployment_target = '11.0'
  s.ios.frameworks = 'Foundation', 'UIKit'

  s.subspec 'Cells' do |ss|
    ss.source_files = 'Source/Cells/**/*.swift'

    ss.dependency 'Minerva/List'

    ss.dependency 'IGListKit', '~> 3.4.0'
    ss.dependency 'RxSwift', '~> 5.0.0'

    ss.ios.deployment_target = '11.0'
    ss.ios.frameworks = 'Foundation', 'UIKit'
  end

  s.subspec 'Convenience' do |ss|
    ss.source_files = 'Source/Convenience/**/*.swift'

    ss.dependency 'Minerva/Coordination'
    ss.dependency 'Minerva/List'

    ss.dependency 'IGListKit', '~> 3.4.0'
    ss.dependency 'RxSwift', '~> 5.0.0'

    ss.ios.deployment_target = '11.0'
    ss.ios.frameworks = 'Foundation', 'UIKit'

    ss.tvos.deployment_target = '11.0'
    ss.tvos.frameworks = 'Foundation', 'UIKit'
  end

  s.subspec 'Coordination' do |ss|
    ss.source_files = 'Source/Coordination/**/*.swift'

    ss.ios.deployment_target = '11.0'
    ss.ios.frameworks = 'Foundation', 'UIKit'

    ss.tvos.deployment_target = '11.0'
    ss.tvos.frameworks = 'Foundation', 'UIKit'
  end

  s.subspec 'List' do |ss|
    ss.source_files = 'Source/List/**/*.swift'

    ss.dependency 'IGListKit', '~> 3.4.0'

    ss.ios.deployment_target = '11.0'
    ss.ios.frameworks = 'Foundation', 'UIKit'

    ss.tvos.deployment_target = '11.0'
    ss.tvos.frameworks = 'Foundation', 'UIKit'
  end

  s.subspec 'Swipe' do |ss|
    ss.source_files = 'Source/Swipe/**/*.swift'

    ss.dependency 'Minerva/Cells'
    ss.dependency 'Minerva/List'

    ss.dependency 'IGListKit', '~> 3.4.0'
    ss.dependency 'RxSwift', '~> 5.0.0'
    ss.dependency 'SwipeCellKit', '~> 2.7.0'

    ss.ios.deployment_target = '11.0'
    ss.ios.frameworks = 'Foundation', 'UIKit'
  end
end
