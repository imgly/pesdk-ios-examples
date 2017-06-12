<p align="center">
    <a target="_blank" href="https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=Android-Demo"><img src="http://static.photoeditorsdk.com/logo.png" alt="PhotoEditor SDK Logo"/></a>
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

Our SDK provides tools for adding photo editing capabilities to your iOS application with a big variety of filters that can be previewed in realtime. Unlike other apps that allow a live preview of filters, the [PhotoEditor SDK](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_term=iOS) even provides a live preview when using high-resolution images. The framework is written in Swift and allows for easy customization.
Additionally we support adding stickers and text in a non-destructive manner, which means that you can change the position, size, scale and order at any given time, even after applying other effects or cropping the photo.

This repository contains two examples. Both examples are identical except for the fact that [one is written in Objective-C](https://github.com/imgly/pesdk-ios-examples/tree/master/Examples/ObjcExample) and [the other is written in Swift](https://github.com/imgly/pesdk-ios-examples/tree/master/Examples/SwiftExample). Both examples use CocoaPods for the integration and do some very basic customization of the SDK. Before compiling any of the examples you will have to install the CocoaPod using `pod install`.

<div class="documentation__disclaimer">
<h4>License Terms</h4>
Make sure you have a commercial license before releasing your app.
A commercial license is required for any app or service that has any form of monetization: This includes free apps with in-app purchases or ad supported applications. Please contact us if you want to purchase the commercial license.
</div>

## Features

* 62 stunning built in filters to choose from.
* Native code: Our rendering engine is based on Apple's Core Image, therefore we dodge all the nasty OpenGL problems other frameworks face.
* iPad support: The PhotoEditor SDK uses auto layout for its views and adapts to each screen size - iPhone or iPad.
* Design filters in Photoshop: With most photo editing frameworks you have to tweak values in code or copy & paste them from Photoshop or your favorite image editor. With our response technology that is a thing of the past. Design your filter in Photoshop, once you are done apply it onto the provided identity image. That will 'record' the filter response - save it, add it as new filter, done!
* Swift: Keeping up with time, we chose Swift as the main development language of the PhotoEditor SDK, leading to leaner easier code.
* Live preview: Filters can be previewed directly in the camera preview.
* Low memory footprint: We were able to reduce our memory footprint significantly.
* Non-destructive: Don't like what you did? No problem, just redo or even discard it.
* Highly customizable: Style the UI as you wish to match your needs.
* Objective-C support: All of our public API is Objective-C compatible.
* Fast: Our renderer uses hardware acceleration and the GPU, which makes it lightning fast.

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

<p><a target="_blank" href="https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=IOS-Build"><img style="display:block" src="http://docs.photoeditorsdk.com/assets/images/guides/ios/v7/product.jpg?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=IOS-Build"></a></p>

## License

Please see [LICENSE](https://github.com/imgly/pesdk-ios-examples/blob/master/LICENSE.md) for licensing details.

# Documentation

For a detailed documentation, please take a look [here](http://docs.photoeditorsdk.com/guides/ios/?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=IOS-Build).

## Author

9elements GmbH, [@PhotoEditorSDK](https://twitter.com/PhotoEditorSDK), [https://www.photoeditorsdk.com](https://www.photoeditorsdk.com/?utm_campaign=Projects&utm_source=Github&utm_medium=PESDK&utm_term=iOS)
