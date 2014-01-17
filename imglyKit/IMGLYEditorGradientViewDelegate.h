//
//  IMGLYEditorGradientViewDelegate.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 07.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMGLYEditorGradientViewDelegate <NSObject>

- (void)userInteractionStarted;
- (void)userInteractionEnded;
- (void)controlPointChanged;

@end


