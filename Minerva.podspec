Pod::Spec.new do |s|
  s.name         = "Minerva"
  s.version      = "1.0.0"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.summary      = "This framework is a lightweight wrapper around IGListKit."

  s.homepage     = "https://github.com/OptimizeFitness/Minerva"
  s.author       = { "Joe Laws" => "joe@optimize.fitness" }

  s.source       = { :git => "https://github.com/OptimizeFitness/Minerva.git", :tag => s.version }
  s.source_files = 'Source/*.swift'

  s.swift_version              = '5.0'
  s.requires_arc               = true

  s.ios.deployment_target      = '11.0'
  s.ios.frameworks             = 'Foundation', 'UIKit'

  s.tvos.deployment_target     = '11.0'
  s.tvos.frameworks            = 'Foundation', 'UIKit'

  s.dependency                 'IGListKit', '~> 3.4.0'
end
