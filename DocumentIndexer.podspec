Pod::Spec.new do |spec|
  spec.name         = 'DocumentIndexer'
  spec.version      = '1.2.0'
  spec.summary      = 'A Swifty wrapper for Apple's Search Kit framework'
  spec.homepage     = 'https://github.com/SergeBouts/DocumentIndexer'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Serge Bouts' => 'sergebouts@gmail.com' }
  spec.osx.deployment_target = '10.12'
  spec.swift_version = '4.2'
  spec.source        = { :git => "#{spec.homepage}.git", :tag => "#{spec.version}" }
  spec.source_files  = 'Sources/DocumentIndexer/**/*.swift'
end
