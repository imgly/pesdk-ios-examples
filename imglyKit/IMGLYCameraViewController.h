//
//  IMGLYCameraViewController.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import <UIKit/UIKit.h>

@protocol IMGLYCameraImageProvider;

typedef NS_ENUM(NSInteger, IMGLYCameraViewControllerResult) {
    IMGLYCameraViewControllerResultCancelled,
    IMGLYCameraViewControllerResultDone
};

typedef void (^IMGLYCameraViewControllerCompletionHandler)(IMGLYCameraViewControllerResult result,
                                                           UIImage *image,
                                                           IMGLYFilterType filterType);

/*
 Shows the live stream of the camera and allows to apply a certain filter on the stream. It also allows to take a photo.
 */
@interface IMGLYCameraViewController : UIViewController

/*
 Specifies a block to be called when the user is finished. This block is not guaranteed to be called on any particular
 thread. It is cleared after being called.
 */
@property (nonatomic, copy) IMGLYCameraViewControllerCompletionHandler completionHandler;

- (instancetype)initWithCameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider;

- (instancetype)initWithCameraImageProvider:(id <IMGLYCameraImageProvider>)imageProvider availableFilterList:(NSArray *)list;

- (instancetype)initWithAvailableFilterList:(NSArray *)list;

/*
    The camera view controller operates in two modes. First the camera mode, and second the accept mode.
    The accept mode is activ when the used has taken a photo, and sees the accept / save controls.
    After another viewcontroller was active e.g. the editor, we must be able to switch back to the
    camera mode. This function allows us to do so.
*/
- (void)restartCamera;

@end
