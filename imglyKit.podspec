Pod::Spec.new do |spec|
  spec.name                     = 'imglyKit'
  spec.version                  = '1.0.0'
  spec.license                  = type: 'Commercial'
  spec.summary                  = 'imglyKit allows you to create stunning images with a nice selection of premium filters.'
  spec.homepage                 = 'https://github.com/imgly/imgly-sdk-ios'
  spec.authors                  = '9elements GmbH' => 'contact@9elements.com'
  spec.source                   = git: 'https://github.com/imgly/imgly-sdk-ios.git', tag: '1.0.0'
  spec.requires_arc             = true
  spec.ios.deployment_target    = '6.0'
  spec.frameworks               = 'Foundation', 'UIKit', 'CoreImage', 'CoreText'
  spec.public_header_files      = 'imglyKit/*.h'
  spec.source_files             = 'imglyKit/*.{h,m}'
  spec.dependency                 'SVProgressHUD', '~> 1.0.0'
end
