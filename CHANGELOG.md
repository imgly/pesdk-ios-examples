## 7.2.0

## Added

* `PhotoEditViewController` has a new property called `hasChanges`, which is `true` if a user applied any changes to a photo.
* `StickerToolControllerOptions` has a new property called `defaultStickerCategoryIndex` that can be used to specify the index of the initially selected sticker category.
* All `UICollectionViewCell` subclasses can be replaced with custom subclasses using `Configuration`'s `replaceClass(_:replacingClass:moduleName:)` method.

## Changed

* `TransformToolController` now sends a `.transformStraightenAngleChange` analytics event for changes of the straighten angle.
* `TransformToolController` now includes `.cropRect`, `.straightenAngle` and `.aspectRatio` attributes in its `.applyChanges` analytics event.
* When adding or removing a sticker a `.stickerAdd` or `.stickerRemove` analytics event is sent with the associated sticker as a `.sticker` attribute. Those events are also sent when adding or removing a sticker by tapping the undo/redo buttons.
* When adding or removing text a `.textAdd` or `.textRemove` analytics event is sent with the associated text as a `.text` attribute. Those events are also sent when adding or removing text by tapping the undo/redo buttons.
* `TextOptionsToolController` now includes `.text`, `.font`, `.textColor`, `.backgroundColor` and `.alignment` attributes in its `.applyChanges` analytics event.

## 7.1.1

## Added

* `CameraViewControllerOptions` includes a `includeUserLocation` property now that is `true` by default. It can be used to stop the camera from asking for the user's location.

## Changed

* `LoggerProtocol` is now a `class` protocol because loggers are required to be reference types in the current implementation.

## Fixed

* Fixed several smaller bugs regarding deserialization.
* Sometimes the cropping area would be resized while modifying the straighten angle.
* Memory is not copied twice anymore during painting fragment restoration.
* The project compiles with Xcode 9 now.

# 7.1.0

## Added

* The camera tags photos with their location now. This only works when using `Data` instances instead of `UIImage` instances to pass the photo around because those strip EXIF data. See `CameraViewController.dataCompletionBlock` for more details.
* We added a default confirmation dialog when dismissing the editor with changes pending. This can be changed or disabled by setting `PhotoEditViewControllerOptions.discardConfirmationClosure`.

## Changed

* The preview image is now automatically resized when a slider overlays the preview at the bottom, so that is always completely visible.
* We replaced the gaussian blur used in the focus tool with a lens blur like effect for much better looking photos. This does not work on the following older devices where we continue to use a gaussian blur due to performance issues:
	* iPad mini 1st, 2nd and 3rd gen
	* iPad 2nd and 3rd gen
	* iPhone 4S
	* iPod touch

## Fixed

* Fixed various issues with the serialization and deserialization features.
* Fixed an issue with different color spaces used for the preview and the thumbnails in the filter tool.
* Stickers now use anti-aliasing.
* The icon of the 'No Frame' cell in the frame tool is now tinted with the cell's `tintColor` to better match other cells.
* The label of the 'Magic' cell in the main menu is now tinted with the cell's `tintColor` when highlighted to better match other cells.
* The `Slider` now sends a `.touchUpInside` event after a `.touchDown` event has been sent without dragging in between.
* When adding a frame to a photo it would sometimes not completely cover the preview image (by about 1 px).
* When selecting a sticker with its `tintMode` set to `.none` and then dismissing the `StickerOptionsToolController`, the color option would be visible for a split second during the dismissal animation.
* The `BoxGradientView` and `CircleGradientView` now only draw themselves while visible, resulting in a minor performance improvement.
* Sprites didn't have the correct position for a split second when opening the frame tool.
* Sprites would be rotated in the wrong direction when the photo has been flipped.
* Text bounding box resizing would be inverted if the image has been flipped and rotated.

# 7.0.1

## Added

* Added the ability to zoom using a pinch gesture within the `CameraViewController`.

## Fixed

* The icon of the 'No Overlay' option in the overlay tool was not using its @2x and @3x variants.
* Fixed a bug with the new filters and adjustments.
* Fixed interface rotation support.

# 7.0

## Changed

* **The SDK has been renamed from `imglyKit` to `PhotoEditorSDK` and all class prefixes have been renamed from `IMGLY` to `PESDK`. Likewise the CocoaPod has been renamed to `PhotoEditorSDK`.**
* We now ship the framework as a DMG file and include the dSYM file and bcsymbolmaps for better debugging. To integrate the dSYM into your final app, please follow the [updated manual integration guide](http://docs.photoeditorsdk.com/guides/ios/v7_1/introduction/getting_started).
* The `PESDK.shared` singleton has been removed. All of its properties are now static properties on the `PESDK` class.
* The default progress view must be set using the static `PESDK.progressView` property instead of the `Configuration` closure.
* The integrated fonts have been changed.
* The `AdjustToolController` has been improved for much better looking and faster adjustments.
* We were able to significantly decrease the size of our filter's lookup images while also improving the filter's performance.
* All asset names have been changed to a consistent naming scheme.
* The overall look and feel of the `FrameToolController` has been improved.
* Custom stickers are now added by setting `Sticker.all`, custom fonts are added by setting `FontImporter.all`, custom frames are added by setting `Frame.all` and custom overlays are added by setting `Overlay.all` instead of using the `Configuration` class.

## Added

* Serialization and deserialization has been added. Because of this many classes (e.g. `Sticker`, `Frame`) now require an `identifier`. For more information please see the documentation.
* The `OverlayToolController` tool has been added, which can be used to add overlays to a photo. Please see the documentation for more information.
* A custom logger with varying log levels was added. See documentation for more information.
* The `Sticker` class now supports `.colorized` as its `tintMode`. See the API documentation for more information.
* A 3:2 crop aspect has been added to `TransformToolController`'s defaults.
* An Emoticon and a Shapes sticker set has been added.
* `TextFontToolControllerOptions` now has a `fontSelectorViewConfigurationClosure` property and a `handleButtonConfigurationClosure` property for better customization.
* `StickerToolControllerOptions` now has a `stickerPreviewSize` property to adjust the size of the stickers in the preview.

## Removed

* The Toy sticker set has been removed.

## Fixed

* The button to show/hide the font selector view within the `TextFontToolController` now respects the view's `tintColor`.
* Full accessibility support has been restored.

# 6.5.4

## Changed

* With the color picker expanded you can now tap anywhere above it to dismiss the color picker.
* We restored iOS 8 compatibility in this release. Please note that this only means that the framework can be integrated into a target with iOS 8 as its deployment target. However most classes and especially all view controllers are *not* available on iOS 8. We strongly advise that you disable any editing functions for users running iOS 8.

# 6.5.3

## Changed

* We replaced the set of included fonts with much better looking fonts.

# 6.5.2

## Fixed

* Fixed a crash when adding text. This was introduced by the Swift 3.1 compiler, see [SR-4393](https://bugs.swift.org/browse/SR-4393) for more details.

# 6.5.1

## Fixed

* Fixed an issue with the `forceCropMode` setting.

# 6.5.0

## Changed

* This version is compiled with Swift 3.1 and can be used with Xcode 8.3. It does not contain any other changes.

# 6.4.2

## Fixed

* Fixed a scaling issue regarding backdrops.

# 6.4.1

## Changed

* Sticker and text overlays have a bigger touch area so that they are easier to grab.

## Fixed

* Fixed a rare crash in `CameraViewController` that occurred when disabling focus lock while deallocating the controller.

# 6.4.0

## Added

* Added a `discardConfirmationClosure` property to `PhotoEditViewControllerOptions` that is called when tapping the cancel button while changes are applied to the image.
* Zooming is now enabled in all tools except for the focus tool.

## Changed

* The overlay buttons (i.e. undo, redo, etc.) in the sticker, text and brush tool have been moved to the bottom.
* `StickerTintMode.tint` has been renamed to `StickerTintMode.solid`.
* `StickerTintMode.ink` has been renamed to `StickerTintMode.colorized`.
* When adding long text the created label breaks the text into multiple lines if the font size would be too small otherwise.
* `IMGLYSetLocalizationDictionary` has been replaced by `PESDK.localizationDirectory`.
* `IMGLYSetLocalizationBlock` has been replaced by `PESDK.localizationBlock`.
* `IMGLYSetBundleImageBlock` has been replaced by `PESDK.bundleImageBlock`.

## Fixed

* `DefaultProgressView` was not positioned correctly when used in an iPad Split View environment.
* The menu collection views were not positioned correctly when used in an iPad Split View environment.

# 6.3.1

## Fixed

* Fixed warnings that are generated by SwiftLint 0.16.1.
* Moved the overlay image generation to a background queue, so that the progress view appears immediately when the user taps the save button.
* Fixed an ambiguous constraints warning in `CameraViewController`.
* Fixed an issue where the loading progress view would disappear while presenting the editor.

# 6.3.0

## Added

* Added an option to change the default color of newly added text (see `TextToolControllerOptions.defaultTextColor`).
* A progress view is displayed while generating the preview image now.
* Tinting of stickers can be enabled on a per sticker basis (see `Sticker.tintMode`).
* Crop Aspect Ratios can be rotated by tapping on an already selected crop aspect (see `CropAspect.isRotatable`).

## Changed

* Changed the default icon of the transform tool.
* The magic tool displays a selected state when active.
* The `.straighten` option has been removed from the default options of `TextOptionsToolController` and `StickerOptionsToolController`.
* The `.flip` option has been removed from the default options of `TextOptionsToolController`.
* The alignment, bring to front, straighten and flip buttons within `TextOptionsToolController` were moved from an overlay into the menu.
* When resizing text the bounding box of the text becomes wider along with the font size.
* While the `BrushColorToolController` is active the user can continue to paint in the canvas.
* Editing text works by just single tapping on an already selected label instead of long pressing.
* The delete button within the brush tool was moved to the top, the bring to front button was moved from an overlay into the menu.
* The flip, straighten and bring to front buttons within `StickerOptionsToolController` were moved from an overlay into the menu.

## Fixed

* Fixed a crash that occurred when opening the transform tool very quickly after presenting the editor.
* Fixed an issue with the brush tool that occurred when opening the brush very quickly after presenting the editor.
* Fixed an issue where the progress view would not disappear when tapping the save button.
* Fixed an issue regarding the frame tool and rotated images.
* Fixed a bug where a crop would sometimes be applied although the user tapped the cancel button.
* When changing a text the changes are reflected in the label while typing.
* Fixed a crash in `CameraController`.

# 6.2.0

## Added

* Support for wide color images. More information is available [here](https://medium.com/imgly/bringing-wide-color-to-photoeditor-sdk-a6ce8bb19ef7#.1nw0egenf).
* Added redo support and optimized undo support. Each time the sticker, text or brush tool is openend, a new undo/redo stack is created and local changes within those tools can be un- and redone. The `PhotoEditViewController` also has support for undo and redo and performs all undo or redo operations of the tools mentioned above combined, either step by step or tool by tool (see `PhotoEditViewControllerOptions.undoStepByStep`).

## Changed

* `M_PI` has been replaced by `.pi`, `FLT_EPSILON` has been replaced by `.ulpOfOne`
* Adding a new sticker from within the `StickerOptionsToolController` now opens the already instantiated `StickerToolController` that was passed to `PhotoEditViewController` instead of creating a new instance.
* The blur radius specified in the `FocusToolController` is now relative to the smaller side of the image instead of an absolute value, which means that the final output image looks like the preview image.

## Fixed

* Fixed a crash that occurred when setting `CameraViewControllerOptions.showFilters` to `false`.

# 6.1.4

## Fixed

* Fixed a crash in `CameraViewController`.
* The `photoActionButtonConfigurationClosure` closure was not called initially.
* Changing the `tintColor` of the button to take a photo works now.

# 6.1.3

## Added

* Added default intensities for blend modes.

## Changed

* Changed some `enum`s to lower case to match Swift 3.0 naming conventions.

## Fixed

* Fixed a memory leak in `CameraViewController`.
* Fixed a memory leak in `FrameToolController`.
* Fixed a scaling issue for backdrop images.
* Fixed the Podspec so that the resource bundle is not added twice to projects that use CocoaPods to integrate the SDK.

# 6.1.2

## Added

* A new API to integrate the SDK into your analytics. See `AnalyticsClient` and `PESDK.shared.analytics` for more details.
* Added an option to set a backdrop image (`backdropImage`), a blend mode (`backdropBlendMode`) and an intensity (`backdropIntensity`) for it to `PhotoEditModel`.

# 6.1.1

## Fixed

* Fixed a bug regarding image orientation that occurred when saving an unedited image. The image that was passed to `PhotoEditViewController` is now passed back to the delegate untouched when saving and image without any modifications.

# 6.1.0

## Added

* Dynamic frames, which are generated during runtime and adjust to the image based on a given set of rules, similar to 9-patch images. See `CustomPatchFrameBuilder` for more information.

## Changed

* Frames participate in the bring-to-front behavior so that stickers, text and brush can be moved behind or in front of frames.
* Licensing has been improved to support multiple bundle identifiers within one license.

# 6.0.1

## Added

* Licensing

# 6.0

## Added

* Stickers can be grouped into individual categories and their color can be changed by the user.
* New initializers for `PhotoEditViewController`: `init(data: Data)`, `init(data: Data, configuration: Configuration)` and `init(data: Data, menuItems: [MenuItem], configuration: Configuration)` which allow passing an image as data in which case EXIF information can be preserved.
* `PhotoEditModel` is a Swift `struct` now. When using Objective-C you can use `IMGLYBoxedPhotoEditModel` instead where needed.

## Changed

* The crop UI has been completely revised and supports arbitrary rotations now.
* Updated the UI of the focus tool so that the user can change the width of the focus gradient.
* Updated the overall look and feel of the UI.
* Custom fonts can be added to the SDK.
* Many performance improvements.
* Asset datasources support remote sources out of the box now.
