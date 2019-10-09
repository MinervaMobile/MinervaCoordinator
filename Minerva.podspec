Pod::Spec.new do |s|
  s.name         = "Minerva"
  s.version      = "2.5.0"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.summary      = "This framework is a lightweight wrapper around IGListKit."

  s.homepage     = "https://github.com/OptimizeFitness/Minerva"
  s.author       = { "Joe Laws" => "joe@optimize.fitness" }

  s.source       = { :git => "https://github.com/OptimizeFitness/Minerva.git", :tag => s.version }

  s.default_subspecs = 'Base', 'Bindable', 'Coordination', 'List'

  s.requires_arc               = true
  s.swift_versions             = '5.1'

  s.ios.deployment_target      = '11.0'
  s.ios.frameworks             = 'Foundation', 'UIKit'

  s.subspec 'Base' do |ss|
    ss.source_files = 'Source/Base/**/*.swift'

    ss.ios.deployment_target      = '11.0'
    ss.ios.frameworks             = 'Foundation', 'UIKit'

    ss.dependency 'Minerva/Coordination'
    ss.dependency 'Minerva/List'

    ss.dependency 'IGListKit', '~> 3.4.0'
  end

  s.subspec 'Bindable' do |ss|
    ss.source_files = 'Source/Bindable/**/*.swift'

    ss.ios.deployment_target      = '11.0'
    ss.ios.frameworks             = 'Foundation', 'UIKit'

    ss.dependency 'Minerva/List'

    ss.dependency 'IGListKit', '~> 3.4.0'
  end

  s.subspec 'Coordination' do |ss|
    ss.source_files = 'Source/Coordination/**/*.swift'

    ss.ios.deployment_target      = '11.0'
    ss.ios.frameworks             = 'Foundation', 'UIKit'
  end

  s.subspec 'List' do |ss|
    ss.source_files = 'Source/List/**/*.swift'

    ss.ios.deployment_target      = '11.0'
    ss.ios.frameworks             = 'Foundation', 'UIKit'

    ss.dependency 'IGListKit', '~> 3.4.0'
  end
end
