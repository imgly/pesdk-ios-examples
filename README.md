<p align="center">
    <a target="_blank" href="https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS"><img src="http://static.photoeditorsdk.com/logo.png" alt="PhotoEditor SDK Logo"/></a>
</p>
<p align="center">
	<a href="https://cocoapods.org/pods/PhotoEditorSDK">
    <img src="https://img.shields.io/cocoapods/v/PhotoEditorSDK.svg" alt="CocoaPods Compatible">
  </a>
	<a href="http://twitter.com/PhotoEditorSDK">
    <img src="https://img.shields.io/badge/twitter-@PhotoEditorSDK-blue.svg?style=flat" alt="Twitter">
  </a>
  <a target="_blank" href="https://pesdk-slack.herokuapp.com/">
    <img src="https://pesdk-slack.herokuapp.com/badge.svg" alt="Slack Status" />
    </a>
</p>

# About PhotoEditor SDK for iOS

## Overview

The [PhotoEditor SDK](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS) is a powerful and multifaceted tool which enables you to equip your iOS application with high-performant photo editing capabilities. The [PhotoEditor SDK](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS) is written in Swift and can easily be customized to entirely blend with your CI and provide your users with the exact feature set your use-case requires. 

The SDK ships with a large variety of filters, covering all state of the art style- and mood settings that can be previewed in real-time. Unlike other apps that allow a live preview of filters, the [PhotoEditor SDK](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS) even provides a live preview when using high-resolution images. 

All operations are non-destructive which allows for fast and uncomplicated revision of the creatives at any given time and creates an intuitive and creative workflow for your users. Please see [Features](https://github.com/imgly/pesdk-ios-examples/blob/master/README.md#features) for a detailed list of the photo editing tools included in the [PhotoEditor SDK](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS).

This repository contains two examples. Both examples are identical except for the fact that one is written in [Objective-C](https://github.com/imgly/pesdk-ios-examples/tree/master/Examples/ObjcExample) and the other is written in [Swift](https://github.com/imgly/pesdk-ios-examples/tree/master/Examples/SwiftExample). Both examples use CocoaPods for the integration and do some very basic customization of the SDK. Before compiling any of the examples you will have to install the CocoaPod using `pod install`.


## License

The PhotoEditorSDK is a product of 9elements GmbH. Please make sure that you have a commercial [license](https://www.photoeditorsdk.com/pricing/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS) before releasing your app. A commercial license is required if you would like to integrate the SDK into any app, regardless of whether you monetize directly (paid app, subscription, service fee), indirectly (advertising, etc.) or are developing a free app. Every license for the PhotoEditor SDK is valid for one product only unless the products are closely related.

If you’d like to use the PhotoEditor SDK for a charitable project, you can do so free of charge. However, please contact us anyway, so we can evaluate whether you qualify for a non-commercial license or not and handle your request accordingly. 

Please [get in touch](https://www.photoeditorsdk.com/pricing/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS) if you’d like to purchase a commercial license or require further information on our pricing and services. Please see the included [LICENSE](https://github.com/imgly/pesdk-ios-examples/blob/master/LICENSE.md) for licensing details.


## Features

* Over 60 handcrafted **Filters** covering all state of the art style- and mood settings to choose from. 
* Design custom filters in Photoshop and other apps: The API of the PhotoEditor SDK enables you to expand the filter library with your own set of custom filters to define a unique visual language. Custom filters can easily be created by anyone using LUTs (Lookup Tables) from popular apps like Photoshop, GIMP or Lightroom. Design your filter and apply it onto the provided identity image. That will 'record' the filter response, now simply save it and add it as a new filter. Done. 
* An **Overlay** Tool that can be used to create neat lighting effects like lens flare or bokeh but also to furnish pictures with textures like crumpled paper or plaster. You can easily expand the library by importing your own set of overlay assets.  
* An **Adjustment section** that holds both essential and advanced photo editing features like brightness, contrast, saturation, clarity etc. that help tweak and fine tune images to create stunning creatives. 
* A **Transform section** that unifies cropping, flipping and rotation in one feature.  
* The robust **Text Feature** provides all necessary functions for quickly adding text to any picture or creative. The corresponding font library can easily be exchanged, reduced, or expanded.
* A categorized **Sticker library** whose UI is optimized for exploration and discovery. You can easily complement the library with your own custom sticker packages.
* A **Frame Tool** that works with any given photo size or ratio.   
* A high performant **Brush Engine** optimized for touch screen that supports different brush strokes.  
* A **Photo Roll** equipped with a wide range of stock photography and templates with presorted categories. The API allows for easy expansion, reduction and rearrangement of the assets. 
* A clean and intuitive **UI** that ensures an unhindered flow of creativity and a seamless experience while composing creatives. The UI is designed to be customized to completely match your CI and blend with your app. 
* You can strip out every feature you deem unnecessary to provide your users with the exact feature set your use case requires. 

* **Native code:** Our rendering engine is based on Apple's Core Image therefore we dodge all the nasty OpenGL problems other frameworks are facing.
* **iPad support:** The PhotoEditor SDK uses auto layout for its views and adapts to each screen size - iPhone or iPad.
* **Swift:** Keeping up with time, we chose Swift as the main development language of the PhotoEditor SDK, leading to leaner, easier code.
* **Live preview:** Filters can be previewed directly in the camera mode even when using high-resolution images.
* **Non-destructive features and effects:** Quickly revise, redo or even discard your work.
* **Objective-C support:** All our public API is Objective-C compatible.
* **Fast:** Our renderer uses hardware acceleration and the GPU, which makes it lightning fast.

### New in Version 7.0

* New stickers, frames and fonts.
* The SDK has been rebranded to `PhotoEditorSDK`.
* We now include the dSYM and bcsymbolmap files in the SDK for better debugging.
* Faster and better looking adjustments.
* Faster and better looking filters.
* The frame tool has been updated to look better than ever before.

### New in Version 6.0

* Updated UI: We've made some UI changes leading to an even better user experience.
* Lots of refactoring and stability improvements
* Updated Sticker Tool: We now support multiple sticker categories and sticker coloring.
* Updated Focus Tool: You can finally adjust the gradient and we've moved from a gaussian blur to a box blur for an even better result.
* Transform Tool: We've completely redesigned and rewritten our crop tool. You can now not only crop your image, but also straighten it.

<p><a target="_blank" href="https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS
"><img style="display:block" src="http://docs.photoeditorsdk.com/assets/images/guides/ios/v7/product.jpg?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS"></a></p>

## License

Please see [LICENSE](https://github.com/imgly/pesdk-ios-examples/blob/master/LICENSE.md) for licensing details.

# Documentation

For a detailed documentation, please take a look [here](http://docs.photoeditorsdk.com/guides/ios/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS).

## Author

9elements GmbH, [@PhotoEditorSDK](https://twitter.com/PhotoEditorSDK), [https://www.photoeditorsdk.com](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_content=iOS-Examples&utm_term=iOS)
