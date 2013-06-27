//
//  FBOOffscreenEAGLView.m
//  FrameBuffer2Texture
//
//  Created on 3/17/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import "FB2GLView.h"
#import <QuartzCore/QuartzCore.h>
#import "WBUtils.h"

@interface FB2GLView()

@end

@implementation FB2GLView
@synthesize layerArray;
@synthesize kTextureSizeWidth, kTextureSizeHeight, kTextureOriginalSize, kTextureScale;
@synthesize kTextureDisplaySizeWidth, kTextureDisplaySizeHeight;
@synthesize currentLayerIndex;
@synthesize numOfLayers;

- (int)numOfLayers {
    return [layerArray count];
}

//KONG: find next Power Of Two since n
static unsigned int NextPot(unsigned int n) {
    n--; 
    n |= n >> 1;  
    n |= n >> 2; 
    n |= n >> 4; 
    n |= n >> 8; 
    n |= n >> 16;
    n++;
    return n;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = NO;
        eaglLayer.backgroundColor = [[UIColor clearColor] CGColor];
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        eaglLayer.contentsScale = [UIScreen mainScreen].scale;
        frameSize = frame.size;
        [self setTextureScale:1];
        
        currentLayerIndex = 0;
        layerArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setTextureScale:(GLint)scale {
    kTextureScale = scale;

    kTextureDisplaySizeWidth = (frameSize.width * kTextureScale);
    kTextureDisplaySizeHeight = (frameSize.height * kTextureScale);
    unsigned int maxSize = (kTextureDisplaySizeWidth > kTextureDisplaySizeHeight) ? 
                                            kTextureDisplaySizeWidth : kTextureDisplaySizeHeight;
    kTextureOriginalSize = NextPot(maxSize);
    
    //KONG: POT texture without GL_CLAMP_TO_EDGE
    kTextureSizeWidth = kTextureOriginalSize;
    kTextureSizeHeight = kTextureOriginalSize;
    
    //KONG: nPOT texture with GL_CLAMP_TO_EDGE, work with iPod gen 3, iPhone 3GS, iPhone 4
//    kTextureSizeWidth = (frameSize.width * kTextureScale);
//    kTextureSizeHeight = (frameSize.height * kTextureScale);            
}

- (void)erase {
    for (currentLayerIndex = 0; currentLayerIndex < self.numOfLayers; currentLayerIndex++) {
        [self setOffscreenFramebuffer];
        
        // Clear the buffer
        glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);        
        
        [self setBackingUndoRedoFramebuffer];
        glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    
    while (self.numOfLayers > 1) {
        [self removeLayer:self.numOfLayers-1];
    }

    if ([layerArray count]) {
        DrawingLayerInfo * firstLayer = (DrawingLayerInfo *)[layerArray objectAtIndex:0];
        firstLayer.offscreenLayerOpacity = YES;
        firstLayer.offscreenLayerOpacity = 1.0f;
        currentLayerIndex = 0;        
    }
}

- (void)setOffscreenFramebuffer {
    
    if (self.context) {
        [EAGLContext setCurrentContext:self.context];
 
        if (!self.numOfLayers)
            [self addNewLayer:YES];
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);
        glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
        
        glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way

    }
}

- (void)setBackingUndoRedoFramebuffer {
    
    if (self.context) {
        [EAGLContext setCurrentContext:self.context];
        
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.URFrameBuffer);
//        glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
        
//        glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way
        
    }
}

//- (void)bindToOffscreenTexture {
//    // update screen texture for further rendering
//    glBindTexture( GL_TEXTURE_2D, offscreenRenderTexture);
//    
//    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, kTextureSizeWidth, kTextureSizeHeight);
////    glCopyTexSubImage2D(GL_TEXTURE, 0, 0, 0, -kTextureSizeWidth/2, -kTextureSizeHeight/2, kTextureSizeWidth, kTextureSizeHeight);
////        glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, kTextureOriginalSize, kTextureOriginalSize);
//    
//    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);  
//}

- (void)setCurrentColorComponentWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    currentColorComponents[0] = red;
    currentColorComponents[1] = green;
    currentColorComponents[2] = blue;
    currentColorComponents[3] = alpha;
}

static GLfloat const textureScale = 1 /* 0.8 */;

- (void)renderOffscreenTexture:(BOOL)drawFullFrame {
    
    static GLfloat textureVertices[8] = {
        1.f * textureScale , -1.f * textureScale,
        1.f * textureScale,  1.f * textureScale,
        -1.f * textureScale,  1.f * textureScale,        
        -1.f * textureScale, -1.f * textureScale,        
    };
    
    const GLfloat textureCoord[8] = { 
        (GLfloat)kTextureDisplaySizeWidth/kTextureOriginalSize, 0,
        (GLfloat)kTextureDisplaySizeWidth/kTextureOriginalSize, (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize,
        0,                                              (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize,
        0,                                              0,
    };
    
    static GLfloat ffTextureVertices[8] = {
        1.f, -1.f,
        1.f,  1.f,
        -1.f,  1.f,        
        -1.f, -1.f,        
    };
    
    static GLfloat ffTextureCoord[8] = { 
        1.f, 0.f,
        1.f,  1.f,
        0.f,  1.f,        
        0.f, 0.f,        
    };
    
    glEnable(GL_BLEND);
    //    glEnable(GL_ALPHA_TEST);
    //    glAlphaFunc(GL_GREATER, 0);    
    glBlendFuncSeparateOES(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
    
    glBindTexture( GL_TEXTURE_2D, backgroundTexture);

    
    if (drawFullFrame) {
        glVertexPointer(2, GL_FLOAT, 0, ffTextureVertices);
        glTexCoordPointer(2, GL_FLOAT, 0, ffTextureCoord);
    } else {
        glVertexPointer(2, GL_FLOAT, 0, textureVertices);
        glTexCoordPointer(2, GL_FLOAT, 0, textureCoord);
    }
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    // get the current color, store it in currentColor array so that we will restore the color selection later
    // otherwise separated opacities for each layer requires glColor4f which may spoil current color setting
    
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
    for (int i = 0; i < self.numOfLayers; i++) {
        DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:i];
        
        if (!layerInfo.offscreenLayerVisible) {
            continue;
        }
        glBindTexture( GL_TEXTURE_2D, layerInfo.offscreenLayerTexture);
        
        // opacity for each layer
        glColor4f(1.0, 1.0, 1.0, layerInfo.offscreenLayerOpacity);
        
        // no need to call glVertexPointer and glTexCoordPointer because we draw to the same coordinate
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        
    }
    
    // restore current color
    glColor4f(currentColorComponents[0], currentColorComponents[1], currentColorComponents[2], currentColorComponents[3]);
    
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    
    //Disable texturing
    glBindTexture( GL_TEXTURE_2D, 0);
}

- (float)opacityOfLayer:(int)index {
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:index];
    return layerInfo.offscreenLayerOpacity;
}

- (void)setLayerOpacity:(CGFloat)opacity atIndex:(int)index {
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:index];
    layerInfo.offscreenLayerOpacity = opacity;
}

- (void)addNewLayer:(BOOL)check {
    if (check) {
        if (self.numOfLayers >= kMaxSupportLayer) {
            return;
        }        
    }

    // The lowest layer needs a white background
    if (backgroundTexture == 0) {
        // prepare white background texture if not setup yet
        glGenTextures(1, &backgroundTexture);
        glBindTexture(GL_TEXTURE_2D, backgroundTexture);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        
        unsigned char * data = (unsigned char *)malloc( kTextureSizeWidth * kTextureSizeHeight * 4 ); 
        
        memset(data, 0x00, kTextureSizeWidth * kTextureSizeHeight * 4);
        
        // each layer must have opacity = 0
        // in order not to overlap layers
        int ii; // red, green, blue, alpha are 4 elements
        for ( ii = 3; ii < kTextureSizeWidth*kTextureSizeHeight*4; ii+=4) {
            // set layer opacity to zero so that multiple layers can be rendered to final render buffer
            data[ii] = 0x0;
        }
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);        
        
        glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, backgroundTexture, 0);
    }
    
    // setup OpenGL layer, store in layerArray
    DrawingLayerInfo * layerInfo = [[DrawingLayerInfo alloc] init];
    [layerArray addObject:layerInfo];
    
    // Offscreen framebuffer object: generate and bind
    glGenFramebuffersOES(1, &layerInfo->offscreenLayerFrameBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.offscreenLayerFrameBuffer);
    
    // Render buffer object: generate and bind
    glGenRenderbuffersOES(1, &layerInfo->offscreenLayerRenderBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, layerInfo.offscreenLayerRenderBuffer);
    
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGBA8_OES, kTextureSizeWidth , kTextureSizeHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, layerInfo.offscreenLayerRenderBuffer);
    
    // Offscreen framebuffer texture: generate and bind texture
    glGenTextures(1, &layerInfo->offscreenLayerTexture);
    glBindTexture(GL_TEXTURE_2D, layerInfo.offscreenLayerTexture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // pre-fill layer with white color
    unsigned char * data = (unsigned char *)malloc( kTextureSizeWidth * kTextureSizeHeight * 4 ); 
    memset(data, 0xff, kTextureSizeWidth * kTextureSizeHeight * 4);

    // each layer must have opacity = 0
    // in order not to overlap layers
    int ii; // red, green, blue, alpha are 4 elements
    for ( ii = 3; ii < kTextureSizeWidth*kTextureSizeHeight*4; ii+=4) {
        // set layer opacity to zero so that multiple layers can be rendered to final render buffer
        data[ii] = 0x0;
    }
    
    layerInfo.offscreenLayerOpacity = 0.0f;
    layerInfo.offscreenLayerVisible = YES;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, kTextureSizeWidth, kTextureSizeHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, layerInfo.offscreenLayerTexture, 0);
    
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    
    
    if (status != GL_FRAMEBUFFER_COMPLETE_OES) {
        DLog(@"error when binding framebuffer object");
        exit(1);
    }
    
    //KONG: set some state for drawing
    glEnable( GL_TEXTURE_2D);
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnable(GL_POINT_SMOOTH);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // setup undo redo backing buffer
    // Offscreen framebuffer object for undo redo backing
    glGenFramebuffersOES(1, &layerInfo->URFrameBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, layerInfo.URFrameBuffer);
    
    // Render buffer object for undo redo backing
    glGenRenderbuffersOES(1, &layerInfo->URRenderBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, layerInfo.URRenderBuffer);
    
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGBA8_OES, kTextureSizeWidth , kTextureSizeHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, layerInfo.URRenderBuffer);
    
    // Offscreen framebuffer texture for undo redo backing
    glGenTextures(1, &layerInfo->URTexture);
    glBindTexture(GL_TEXTURE_2D, layerInfo.URTexture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, kTextureSizeWidth, kTextureSizeHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, layerInfo.URTexture, 0);
    
    status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    
    
    if (status != GL_FRAMEBUFFER_COMPLETE_OES) {
        DLog(@"error when binding framebuffer object");
        exit(1);
    }
    
    //KONG: set some state for drawing
    glEnable( GL_TEXTURE_2D);
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnable(GL_POINT_SMOOTH);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    free(data);
}


- (BOOL)removeLayer:(int)index {
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:index];
    
    // delete texture, frame buffer, render buffer
    glDeleteFramebuffers(1, &layerInfo->offscreenLayerFrameBuffer);
    glDeleteRenderbuffersOES(1, &layerInfo->offscreenLayerRenderBuffer);
    glDeleteTextures(1, &layerInfo->offscreenLayerTexture);

    glDeleteFramebuffers(1, &layerInfo->URFrameBuffer);
    glDeleteRenderbuffersOES(1, &layerInfo->URRenderBuffer);
    glDeleteTextures(1, &layerInfo->URTexture);
    
    [layerArray removeObject:layerInfo];

    if (index == currentLayerIndex) {
        if (currentLayerIndex != 0) {
            currentLayerIndex--;
            // remove the last layer in the array
            // we need to update currentLayerIndex because it points to last index which was already removed
        } else {
            // currentLayerIndex stays the same
        }
        
    } else if (currentLayerIndex < index) {
        // currentLayerIndex stays the same
        
    } else if (currentLayerIndex > index) {
        currentLayerIndex--;
    }
    
    return YES;
}

// Only copy all layers content to export to image or something likes that
- (GLuint)copyAllLayerContentToFrameBuffer:(GLint)width height:(GLint)height {
    //DLog();
    
    GLuint nTexID_out = 0;
    GLuint nFbo = 0;
    GLuint nRbo = 0;
    
    glGenFramebuffersOES(1, &nFbo);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, nFbo);
    
    glGenRenderbuffersOES(1, &nRbo);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, nRbo);
    
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGBA8_OES, width , height);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, nRbo);      
    
    // Offscreen framebuffer texture target
    glGenTextures(1, &nTexID_out);
    glBindTexture(GL_TEXTURE_2D, nTexID_out);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //    unsigned char * data = (unsigned char *)malloc( kTextureSizeWidth * kTextureSizeHeight * 4 ); 
    //    memset( data,
    //           0xff
    //           , kTextureSizeWidth * kTextureSizeHeight * 4 );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);    
    
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, nTexID_out, 0);
    
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    
    
    if (status != GL_FRAMEBUFFER_COMPLETE_OES) {
        DLog(@"error when binding framebuffer object");
        exit(1);
    }
    
    
    //KONG: set some state for drawing
    glEnable( GL_TEXTURE_2D);
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        DLog(@"glGetError 4 (): %d", (int)err);
    
    glBindFramebufferOES( GL_FRAMEBUFFER_OES, nFbo);
    glViewport(0, 0, width, height);
    
    
    // Get the current view port to restore back after drawing
    //    GLint viewport[4];
    //    glGetIntegerv( GL_VIEWPORT, viewport );
    // Prepare to draw (map) source texture to destination texture    
    
    [self renderOffscreenTexture:YES];
    
    // unbind texture and frame buffer
    glBindTexture( GL_TEXTURE_2D , 0 );
    glBindFramebufferOES( GL_FRAMEBUFFER_OES, 0 );
    glDeleteTextures(1, &nTexID_out);
    glDeleteRenderbuffersOES(1, &nRbo);
    //    glDeleteFramebuffersOES( 1, &nFbo );
    
    
    // Restore the old view port
    //    glViewport( viewport[0],viewport[1],viewport[2],viewport[3]);
    
    return nFbo;
}

// Load the undo redo backing texture into current buffer context
- (void)renderBackingUndoRedoTexture {
    
    GLfloat textureVertices[] = {
        0, 0, 0,
        kTextureDisplaySizeWidth, 0, 0,
        0, kTextureDisplaySizeHeight, 0,
        kTextureDisplaySizeWidth, kTextureDisplaySizeHeight, 0
	};
	
	GLfloat textureCoord[8] = { 
        0, 0,
        (GLfloat)kTextureDisplaySizeWidth/kTextureOriginalSize, 0,
        0,                                              (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize,
        (GLfloat)kTextureDisplaySizeWidth/kTextureOriginalSize, (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize
        
    };
    
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
    
    glEnable(GL_BLEND);
	glBindTexture( GL_TEXTURE_2D, layerInfo.URTexture);
    
    glBlendFuncSeparateOES(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    
	glVertexPointer(3, GL_FLOAT, 0, textureVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoord);
//	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	

    glBindTexture( GL_TEXTURE_2D, 0);
}

- (void)copyLayerContentToBURBuffer:(int)layerIndex {
    glPushMatrix();
    glLoadIdentity();
    
    [self setBackingUndoRedoFramebuffer];
    glViewport(0, 0, kTextureOriginalSize, kTextureOriginalSize);
    glOrthof(0, kTextureOriginalSize, 0, kTextureOriginalSize, -1, 1); // the cocos2d way
    
    GLfloat ffTextureVertices[8] = {
        1.f * textureScale, -1.f * textureScale,
        1.f * textureScale,  1.f * textureScale,
        -1.f * textureScale,  1.f * textureScale,        
        -1.f * textureScale, -1.f * textureScale,        
    };
    
    GLfloat ffTextureCoord[8] = { 
        (GLfloat)kTextureDisplaySizeWidth/kTextureOriginalSize, 0.f,
        (GLfloat)kTextureDisplaySizeWidth/kTextureOriginalSize,  (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize,
        0.f,  (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize,        
        0.f, (GLfloat)kTextureDisplaySizeHeight/kTextureOriginalSize,        
    };
    
    DrawingLayerInfo * layerInfo = [layerArray objectAtIndex:currentLayerIndex];
    glBindTexture( GL_TEXTURE_2D, layerInfo.offscreenLayerTexture);
    
    glVertexPointer(2, GL_FLOAT, 0, ffTextureVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, ffTextureCoord);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glBindTexture( GL_TEXTURE_2D, 0);
    
    glPopMatrix();
}

- (void)moveLayerAtIndex:(NSInteger)index1 toIndex:(NSInteger)index2 {
    id object = [layerArray objectAtIndex:index1];
    [layerArray removeObjectAtIndex:index1];
    [layerArray insertObject:object atIndex:index2];
}

- (void)dealloc {
    [self removeLayer:0];
}

@end