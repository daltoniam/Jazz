Pod::Spec.new do |s|
  s.name         = "Jazz"
  s.version      = "2.0.2"
  s.summary      = "Easier layer animations in Swift"
  s.homepage     = "https://github.com/daltoniam/Jazz"
  s.license      = 'Apache License, Version 2.0'
  s.author       = {'Dalton Cherry' => 'http://daltoniam.com'}
  s.source       = { :git => 'https://github.com/daltoniam/Jazz.git',  :tag => "#{s.version}"}
  s.social_media_url = 'http://twitter.com/daltoniam'
  s.ios.deployment_target = '9.0'
  s.source_files = '*.swift'
  s.requires_arc = 'true'
end
