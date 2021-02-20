Pod::Spec.new do |s|
  s.name = "MinervaCoordinator"
  s.version = "3.0.0"
  s.license = { :type => 'MIT', :file => 'LICENSE' }

  s.summary = "A Swift Coordinator Framework"
  s.homepage = "hhttps://github.com/MinervaMobile/MinervaCoordinator"
  s.author = { "Joe Laws" => "joe.laws@gmail.com" }

  s.source = { :git => "https://github.com/MinervaMobile/MinervaCoordinator.git", :tag => s.version }

  s.default_subspecs = 'Coordination'

  s.requires_arc = true
  s.swift_versions = '5.3'

  s.ios.deployment_target = '11.0'
  s.ios.frameworks = 'Foundation', 'UIKit'

  s.subspec 'Coordination' do |ss|
    ss.source_files = 'Source/Coordination/**/*.swift'

    ss.ios.deployment_target = '11.0'
    ss.ios.frameworks = 'Foundation', 'UIKit'

    ss.tvos.deployment_target = '11.0'
    ss.tvos.frameworks = 'Foundation', 'UIKit'
  end

end
