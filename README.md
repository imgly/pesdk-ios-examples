![img.ly](http://i.imgur.com/fgH1HRt.png)

## img.ly SDK for iOS

img.ly SDK for iOS is a Cocoa Touch framework for creating stunning images with a nice selection of premium filters.

### Overview

img.ly SDK provides tools to create photo applications for iOS with a big variety of filters that can be previewed in real-time. Unlike other apps that allow live preview of filters img.ly SDK provides high-resolution images. On iPhone 4 that is 2048 x 1593 pixels and on iPhone 5 full resolution (up to 4096 x 4096 pixels). It also comes with customizable view controllers for the general needs of such apps.

![Example](http://i.imgur.com/EorDrpS.png)

### Installation

The easiest way to install img.ly SDK for iOS is via CocoaPods. In your Podfile, add the following:

    pod 'imglyKit'


### High level API

First there is the `IMGLYCameraViewController`. That controller shows a camera live stream, a filter selector, and UI controls to control the camera settings such as flash, front camera or back camera. After the user took an image the controller switches to accept mode. In that mode the user can accept (edit) the image, save it , or reject it. Also he can change the filter.

The other of the two public view controllers is the `IMGLYEditorViewController`. That controller allows the user to edit an image. The options are, Magic (automatic image enhancement), filter, orientation (flip rotate), focus (tiltshift), crop, brightness, contrast, saturation, noise, text. Also there is a reset / undo option that lets the user start over. Each of the view controllers provides a completion block, that returns the final high resolution image.

The img.ly SDK comes with an example app that shows different setups to demonstrate the simplicity and power of the SDK. Starting from the `didFinishLaunchingWithOptions` method, `startupWithCamera`, `startupWithEditor` or `startupWithImageSelector` can be called to setup the app in the chosen mode.

For example, `startupWithCamera` will start the app with the `IMGLYCameraViewController`. The method also set a `IMGLYCameraViewControllerCompletionHandler`. That is used to initiate an `IMGLYEditorViewController` when the user chose 'edit'. The new `IMGLYEditorViewController` will be pushed to the `UINavigationController`. After that view controller is dismissed the `IMGLYCameraViewController` will become active again. SwitchToCameraMode is called to set the controller back to photo-taking mode.

Both view controllers provide multiple init functions, with combinations of different parameters. Those parameters are: `id<IMGLYCameraImageProvider>imageProvider`. The imageProvider can be used to give the UI a different look. It must implement the `IMGLYCameraImageProvider` protocol. That protocol consists of getters for the individual images. Such as the camera button, or the background images. When no image provider is set, the SDK will use the default images. Also, the preview image for the filters, during live stream, is set via that protocol. See `IMGLYDefaultCameraImageProvider` class for more infos on that matter.

The `IMGLYEditorImageProvider` is the equivalent protocol for the `IMGLYEditorViewController`.

Another parameter is the `availableFilterList`. That is actually a `NSArray` of integers derived from the desired filter types. In our example app the `listOfAvailableFilters` method returns such an array. If that parameter is `nil` or not set, all filters of the SDK will be added. Note that this array also controls the order of the filters.

The `IMGLYEditorViewController` also has a parameter for the initial filter type. Using that parameter will add a filter to the image so its preview will look like the one in the `IMGLYCameraController`.

To get how the high level of the img.ly SDK works, read the source code of the example app carefully.


### Low level API

As low-level API the SDK comes with the `IMGLYPhotoProcessor` class. It can be used to apply filters and other operations directly from code. The `IMGLYPhotoProcessor` is a singleton. That is necessary to avoid threading issues with OpenGLES. To work with the `IMGLYPhotoProcessor` a `IMGLYProcessingJob` must be created. It holds a list of `IMGLYOperations` that we add to the job. That job then is handed over to the `IMGLYPhotoProcessor` and will be executed.

Here is an example that creates a `IMGLYFilterOperation`:

    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYFilterOperation *operation = [[IMGLYFilterOperation alloc] init];
    operation.filterType = IMGLYFilterType669;
    [job addOperation:(IMGLYOperation *)operation];

Note that we only add one operation here, but multiple operations can be added. After the job was setup we set the input image and run the job:

    UIImage *inputImage= ...;
    [IMGLYPhotoProcessor sharedPhotoProcessor].inputImage = inputImage;
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    UIImage *outputImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];


### Attribution

img.ly SDK for iOS uses a private fork of [GPUImage](https://github.com/BradLarson/GPUImage), which is released under the following license:

    Copyright (c) 2012, Brad Larson, Ben Cochran, Hugues Lismonde, Keitaroh Kobayashi, Alaric Cole, Matthew Clark, Jacob Gundersen, Chris Williams. All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    Neither the name of the GPUImage framework nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


### License

Please see [LICENSE](https://github.com/imgly/imgly-sdk-ios/blob/master/LICENSE) for licensing details.


### Author

9elements GmbH, [@9elements](https://twitter.com/9elements), [http://www.9elements.com](http://www.9elements.com)
