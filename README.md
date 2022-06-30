<p align="center">
	<a href="https://img.ly/photo-sdk?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=IOS-Build">
		<img src="https://img.ly/static/logos/PE.SDK_Logo.svg" alt="PhotoEditor SDK Logo"/>
	</a>
</p>
<p align="center">
	<a href="https://swiftpackageindex.com/imgly/pesdk-ios-build">
		<img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fimgly%2Fpesdk-ios-build%2Fbadge%3Ftype%3Dplatforms" alt="Swift Package Manager Compatible">
	</a>
	<a href="https://swiftpackageindex.com/imgly/pesdk-ios-build">
		<img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fimgly%2Fpesdk-ios-build%2Fbadge%3Ftype%3Dswift-versions" alt="Swift Package Manager Compatible">
	</a>
	<a href="https://cocoapods.org/pods/PhotoEditorSDK">
		<img src="https://img.shields.io/cocoapods/v/PhotoEditorSDK.svg?label=Pod" alt="CocoaPods Compatible">
	</a>
	<a href="http://twitter.com/PhotoEditorSDK">
		<img src="https://img.shields.io/badge/twitter-@PhotoEditorSDK-blue.svg?label=Twitter&style=flat" alt="Twitter">
	</a>
</p>

**You can find our latest examples at https://github.com/imgly/catalog-ios.**

# About PhotoEditor SDK for iOS

Our SDK provides tools for adding photo editing capabilities to your iOS application with a big variety of filters that can be previewed in realtime. Unlike other apps that allow a live preview of filters, the PhotoEditor SDK even provides a live preview when using high-resolution images. The framework is written in Swift and allows for easy customization.
Additionally, we support adding stickers and text in a non-destructive manner, which means that you can change the position, size, scale, and order at any given time, even after applying other effects or cropping the photo.

## How to run the examples

The example projects are preconfigured to use the [Swift Package Manager](https://img.ly/docs/pesdk/ios/introduction/getting_started/#swift-package-manager) to install PhotoEditor SDK.

To get started open `PESDKExamples.xcworkspace` with Xcode 13.3+ and run the example projects.

## Features

- Over 60 handcrafted **Filters** covering all state of the art style- and mood settings to choose from.
- Design custom filters in Photoshop and other apps: The API of the PhotoEditor SDK enables you to expand the filter library with your own set of custom filters to define a unique visual language. Custom filters can easily be created by anyone using LUTs (Lookup Tables) from popular apps like Photoshop, GIMP or Lightroom. Design your filter and apply it onto the provided identity image. That will 'record' the filter response, now simply save it and add it as a new filter. Done.
- An **Overlay** Tool that can be used to create neat lighting effects like lens flare or bokeh but also to furnish pictures with textures like crumpled paper or plaster. You can easily expand the library by importing your own set of overlay assets.
- An **Adjustment section** that holds both essential and advanced photo editing features like brightness, contrast, saturation, clarity etc. that help tweak and fine tune images to create stunning creatives.
- A **Transform section** that unifies cropping, flipping and rotation in one feature.
- The robust **Text Feature** provides all necessary functions for quickly adding text to any picture or creative. The corresponding font library can easily be exchanged, reduced, or expanded.
- A categorized **Sticker library** whose UI is optimized for exploration and discovery. You can easily complement the library with your own custom sticker packages.
- A **Frame Tool** that works with any given photo size or ratio.
- A high performant **Brush Engine** optimized for touch screen that supports different brush strokes.
- A **Photo Roll** equipped with a wide range of stock photography and templates with presorted categories. The API allows for easy expansion, reduction and rearrangement of the assets.
- A clean and intuitive **UI** that ensures an unhindered flow of creativity and a seamless experience while composing creatives. The UI is designed to be customized to completely match your CI and blend with your app.
- You can strip out every feature you deem unnecessary to provide your users with the exact feature set your use case requires.
- **iPad support:** The PhotoEditor SDK uses auto layout for its views and adapts to each screen size - iPhone or iPad.
- **Swift:** Keeping up with time, we chose Swift as the main development language of the PhotoEditor SDK, leading to leaner, easier code.
- **Live preview:** Filters can be previewed directly in the camera mode even when using high-resolution images.
- **Non-destructive features and effects:** Quickly revise, redo or even discard your work.
- **Objective-C support:** All our public API is Objective-C compatible.
- **Fast:** Our renderer uses hardware acceleration and the GPU, which makes it lightning fast.

## Integration

For a step-by-step guide to integrate PhotoEditor SDK, please visit [img.ly/docs/pesdk/guides/ios](https://img.ly/docs/pesdk/guides/ios?utm_campaign=Projects&utm_source=Github&utm_medium=Side_Projects&utm_content=IOS-Build).

## License Terms

Make sure you have a commercial license before releasing your app.
A commercial license is required for any app or service that has any form of monetization: This includes free apps with in-app purchases or ad supported applications. Please contact us if you want to purchase the commercial license.

## Support

Please use our [Service Desk](https://support.img.ly) if you have any questions or would like to submit bug reports.
