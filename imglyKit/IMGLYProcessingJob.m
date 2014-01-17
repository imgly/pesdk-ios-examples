//
//  IMGLYProcessingJob.m
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYProcessingJob.h"

#import "IMGLYOperation.h"

@interface IMGLYProcessingJob ()

@property (nonatomic, strong) NSMutableArray *internalOperations;

@end

#pragma mark -

@implementation IMGLYProcessingJob

- (instancetype)init {
    self = [super init];
    if (self) {
        _internalOperations = [NSMutableArray array];
    }
    return self;
}

- (void)addOperation:(IMGLYOperation *)operation {
    [self.internalOperations addObject:operation];
}

- (NSArray *)operations {
    return [self.internalOperations copy];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString string];
    [description appendString:@"\n"];
    [description appendFormat:@"Class: %@\n", NSStringFromClass([self class])];
    [description appendString:@"---\n"];
    [description appendFormat:@"Operation Count: %lld\n", (long long)[self.internalOperations count]];
    [description appendString:@"Operation Classes:\n"];

    for (id <IMGLYOperation> operation in self.internalOperations) {
        [description appendFormat:@" -> %@", NSStringFromClass([operation class])];
    }

    return description;
}


- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        for (id <IMGLYOperation> operation in self.internalOperations) {
            [copy addOperation:[operation copy]];
        }
    }
    
    return copy;
}

@end
