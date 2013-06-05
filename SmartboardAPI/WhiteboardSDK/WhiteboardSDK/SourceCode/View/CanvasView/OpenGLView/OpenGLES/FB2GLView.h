//
//  FBOOffscreenEAGLView.h
//  FrameBuffer2Texture
//
//  Created on 3/17/11.
//  Copyright 2013 Greengar. All rights reserved.
//  This is the Base Open GL Rendering View
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "DrawingLayerInfo.h"

#define kMaxSupportLayer 3   // maximum 3 layers

@interface FB2GLView : EAGLView {
    
    CGSize frameSize;
    GLint kTextureSizeWidth, kTextureSizeHeight, kTextureOriginalSize, kTextureScale;
    GLint kTextureDisplaySizeWidth, kTextureDisplaySizeHeight;
        
    GLuint backgroundTexture;

    int    currentLayerIndex; // 0 means drawing on main offscreenRenderTexture

    // we add one extra layer for text mode
    NSMutableArray * layerArray;
    
    // used for fast restoring glColor4f after rendering all layers
    CGFloat          currentColorComponents[4];
}

@property (nonatomic) GLint kTextureSizeWidth, kTextureSizeHeight, kTextureOriginalSize, kTextureScale;
@property (nonatomic) GLint kTextureDisplaySizeWidth, kTextureDisplaySizeHeight;
@property (nonatomic, retain) NSMutableArray * layerArray;

@property (nonatomic) int    currentLayerIndex; // 0 means drawing on main offscreenRenderTexture
@property (nonatomic, readonly) int    numOfLayers;

- (id)initWithFrame:(CGRect)frame;

//KONG: this method set dimension for offscreen framebuffer
// call this method before call setOffscreenFramebuffer
- (void)setTextureScale:(GLint)scale;

- (void)setOffscreenFramebuffer;
- (void)setBackingUndoRedoFramebuffer;
- (void)renderOffscreenTexture:(BOOL)drawFullFrame;
- (void)renderBackingUndoRedoTexture;

// used when exporting canvas content to image file
- (GLuint)copyAllLayerContentToFrameBuffer:(GLint)width height:(GLint)height;

// erase content of canvas, reset all layers
- (void)erase;

// managing layers
#pragma mark Managing Layers
- (void)addNewLayer:(BOOL)check;
- (BOOL)removeLayer:(int)index;
- (float)opacityOfLayer:(int)index;
- (void)setLayerOpacity:(CGFloat)opacity atIndex:(int)index;
- (void)copyLayerContentToBURBuffer:(int)layerIndex;
- (void)moveLayerAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2;

// used for fast restoring glColor4f after rendering all layers
- (void)setCurrentColorComponentWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end
