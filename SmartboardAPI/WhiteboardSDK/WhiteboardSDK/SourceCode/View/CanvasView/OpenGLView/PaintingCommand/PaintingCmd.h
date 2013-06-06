//
//  PaintingCmd.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class MainPaintingView;
@interface PaintingCmd : NSObject

@property (nonatomic, strong) NSString              *uid;
@property (nonatomic)         int                   layerIndex;
@property (nonatomic, assign) MainPaintingView      *drawingView;

- (id)initWithDict:(NSDictionary *)dict;
- (void)doPaintingAction;
- (NSDictionary *)saveToDict;
+ (PaintingCmd *)loadFromDict:(NSDictionary *)dict;

@end
