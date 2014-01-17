//
//  IMGLY9EK6Filter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLY9EK6Filter.h"

@implementation IMGLY9EK6Filter

- (id)init {
    self = [super init];
    if (self) {
        self.saturation = 0.5;
    }
    
    return self;
}

@end
