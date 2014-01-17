//
//  IMGLYProcessingJob.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMGLYOperation;

/**
 A processing job encapsulates operations that an IMGLYPhotoProcessor can process.
 */
@interface IMGLYProcessingJob : NSObject  <NSCopying>

@property (nonatomic, strong, readonly) NSArray *operations;

- (void)addOperation:(IMGLYOperation *)operation;

@end
