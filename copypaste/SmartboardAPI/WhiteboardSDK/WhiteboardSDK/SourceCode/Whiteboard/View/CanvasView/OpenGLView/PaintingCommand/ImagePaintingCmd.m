//
//  ImagePaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "ImagePaintingCmd.h"
#import "MainPaintingView.h"
#import "WBUtils.h"
#import "NSData+WBBase64.h"

@implementation ImagePaintingCmd

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setCGIImage:(CGImageRef)img {
    image = img;
}

- (void)doPaintingAction {
    if (image) {
        glPushMatrix();
        
        float scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1;
		
		size_t imageW = self.drawingView.bounds.size.width * scale;
		size_t imageH = self.drawingView.bounds.size.height * scale;
		
		// DLog(@"load Image size: %lo %lo", imageW, imageH);
		
		GLubyte *textureData = (GLubyte *) malloc(imageW * imageH << 2);
		GLuint undoTextureId = 0;
        
		if (textureData == nil) {
			DLog(@"Error: textureData == nil");
			// TODO: tell user
		}
		
		CGContextRef imageContext = CGBitmapContextCreate( textureData, imageW, imageH, 8, imageW << 2 /* 2048 */, CGImageGetColorSpace(image), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast );
		CGContextSaveGState(imageContext);  
        
		if( imageContext != NULL )
		{            
			CGContextTranslateCTM(imageContext, 0, imageH);
			CGContextScaleCTM(imageContext, 1.0, -1.0);
			CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)imageW, (CGFloat)imageH), image);
			
			undoTextureId = [self.drawingView loadTextureFromBuffer:textureData
                                                              width:imageW
                                                             height:imageH];
            
			CGContextRestoreGState(imageContext);  
			CGContextRelease(imageContext);
		}
		
		
		free(textureData);
        
        if (undoTextureId) {
            GLfloat quatVertices[] = {
                -1.f, -1.f,
                -1.f, 1.f,
                1.f, 1.f,        
                1.f, -1.f,
            };
            
            GLfloat textureCoord[8] = { 
                0.f, 0.f,
                0.f, 1.f,
                1.f, 1.f,
                1.f, 0.f,
            };
            
            
            glBindTexture(GL_TEXTURE_2D, undoTextureId);
            
            glVertexPointer(2, GL_FLOAT, 0, quatVertices);
            glTexCoordPointer(2, GL_FLOAT, 0, textureCoord);
            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        }
        
        glPopMatrix();
	}
}

- (void)dealloc {
    CGImageRelease(image);
    image = nil;
}

@end
