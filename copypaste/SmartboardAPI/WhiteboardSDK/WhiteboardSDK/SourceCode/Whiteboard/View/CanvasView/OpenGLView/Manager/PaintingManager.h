//
//  PaintingManager.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Painting.h"

#define kCollaborator @"collaborator"
#define kExternalScreen @"externalScreen"

@class PaintingManager;

@protocol PaintingManagerDelegate 
- (void)colorChanged:(CGFloat*)color isSelf:(BOOL)is;
- (void)pointSizeChanged:(CGFloat)pointSize isSelf:(BOOL)is;
@end

@interface PaintingManager : NSObject {
    Painting * me;
    Painting * external;
    Painting * collaborator;
    Painting * current;
    NSMutableSet <PaintingManagerDelegate> *  _callbacks;
}

+ (PaintingManager *)sharedManager;

- (void)updateColor:(CGColorRef)color of:(id)whiteboard;
- (void)updateOpacity:(CGFloat)opacity of:(id)whiteboard;
- (void)updatePointSize:(CGFloat)pointSize of:(id)whiteboard;
- (void)updateDevice:(GSDevice)inDevice of:(id)whiteboard;

- (void)registerCallback:(id)callback;
- (void)removeCallback:(id)callback;
- (void)removeAllCallbacks;

- (CGFloat *)getColorOf:(id)whiteboard;
- (CGFloat)getPointSizeOf:(id)whiteboard;
- (GSDevice)getDeviceOf:(id)whiteboard;
- (Painting*)getPainting:(id)whiteboard;
- (CGFloat *)getColor;
- (CGFloat)getPointSize;

@end
