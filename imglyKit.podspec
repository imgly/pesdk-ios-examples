Pod::Spec.new do |s|
	s.name             = "imglyKit"
	s.version          = "2.1.0"
	s.license          = { :type => 'Copyright', :file => 'LICENSE' }
	s.summary          = "Creates stunning images with a nice selection of premium filters."
	s.homepage         = "https://github.com/imgly/imgly-sdk-ios"
	s.social_media_url = 'https://twitter.com/9elements'
	s.authors          = { '9elements GmbH' => 'contact@9elements.com' }
	s.source           = { :git => 'https://github.com/imgly/imgly-sdk-ios.git', :tag => s.version.to_s }

	s.platform     = :ios, '8.0'
	s.requires_arc = true

	s.source_files = 'Pod/Classes/**/*'
	s.resources = ['Pod/Assets.xcassets', 'Pod/Filter Responses/*.png', 'Pod/Fonts/*', 'Pod/en.lproj/Localizable.strings']

	s.frameworks = 'Accelerate', 'AVFoundation', 'CoreImage', 'Foundation', 'GLKit', 'MobileCoreServices', 'OpenGLES', 'Photos', 'UIKit'
end
