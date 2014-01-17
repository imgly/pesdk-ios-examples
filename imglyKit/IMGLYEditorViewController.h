//
//  IMGLYEditorViewController.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYAbstractEditorBaseViewController.h"
#import "IMGLYEditorImageProvider.h"
#import "IMGLYFilter.h"

#import <UIKit/UIKit.h>

/**
 IMGLYEditorViewController provides editing capabilities for photos.
 */
@interface IMGLYEditorViewController : UIViewController

/**
 Specifies the image to edit. The edit is non-destructive.
 */
@property (nonatomic, strong) UIImage *inputImage;

/**
 The selected filter type.
 */
@property (nonatomic, assign) IMGLYFilterType filterType;

/**
 The filter types that should be available to the user.
 */
@property (nonatomic, copy) NSArray *availableFilterList;

/**
 An object to customize the visual elements of the view controller.
 */
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

/**
 IMGLYEditorViewControllerCompletionHandler is used to provide the results of the editprocess.
 It will provide the mode i.e. done or cancle, plus the processed image, and the job.
 The job will contain all used operations, and can be used for stack processing or similar.
 */
@property (nonatomic, copy) IMGLYEditorViewControllerCompletionHandler completionHandler;

- (void)resetAllChanges;

@end
