//
//  DrawingLayerInfo.h
//  SmartDrawingSDK
//
//  Created by Nguyen Hoang Long on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingLayerInfo : NSObject {
    @public
    BOOL    offscreenLayerVisible;
    CGFloat offscreenLayerOpacity;
    
    GLuint offscreenLayerTexture;
    GLuint offscreenLayerFrameBuffer;
    GLuint offscreenLayerRenderBuffer;
    
    // undo redo buffer
    // undo redo buffer is updated *lag* . i.e. content of URbuffer is n strokes after of frame buffer of the same layer
    GLuint URTexture;
	GLuint URRenderBuffer;
    GLuint URFrameBuffer;
}

@property (nonatomic) BOOL    offscreenLayerVisible;
@property (nonatomic) CGFloat offscreenLayerOpacity;

@property (nonatomic) GLuint offscreenLayerTexture;
@property (nonatomic) GLuint offscreenLayerFrameBuffer;
@property (nonatomic) GLuint offscreenLayerRenderBuffer;

@property (nonatomic) GLuint URTexture;
@property (nonatomic) GLuint URRenderBuffer;
@property (nonatomic) GLuint URFrameBuffer;

@end
