//
//  ExplorerController.h
//  46px
//
//  Created by Ben Gotow on 7/14/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SparkServer;
@class ExplorerNotificationState;
@class ExplorerViewState;

@interface SparkInspector : NSObject
{
    SparkServer                 * _server;
    NSMutableArray              * _connections;
    NSDictionary                * _preferences;
    
    BOOL                          _classesSwizzled;
    NSMutableDictionary         * _classAttributes;
    NSMutableDictionary         * _classDirtyMethods;
    NSMutableDictionary         * _shorthands;
    
    ExplorerNotificationState   * _notificationState;
    ExplorerViewState           * _viewState;
}

+ (SparkInspector*)sharedClient;
+ (void)enableObservation;

@end

