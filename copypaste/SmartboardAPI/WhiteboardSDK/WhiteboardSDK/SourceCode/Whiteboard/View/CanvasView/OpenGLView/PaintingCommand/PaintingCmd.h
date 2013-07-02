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
@class WBBaseElement;
@interface PaintingCmd : NSObject

@property (nonatomic, strong) NSString              *uid;
@property (nonatomic)         int                   layerIndex;
@property (nonatomic, weak) MainPaintingView      *drawingView;

- (void)doPaintingAction;
- (NSMutableDictionary *)saveToDataWithElementUid:(NSString *)elementUid
                                          pageUid:(NSString *)pageUid
                                       historyUid:(NSString *)historyUid;
- (void)loadFromData:(NSDictionary *)paintingData forElement:(WBBaseElement *)element;

@end