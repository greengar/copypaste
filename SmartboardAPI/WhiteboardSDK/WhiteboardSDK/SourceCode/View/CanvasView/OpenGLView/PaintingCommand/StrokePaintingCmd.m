//
//  StrokePaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "StrokePaintingCmd.h"
#import "MainPaintingView.h"
#import "WBUtils.h"

@implementation StrokePaintingCmd

- (void)strokeFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    startPoint = CGPointMake(start.x, start.y);
    endPoint = CGPointMake(end.x, end.y);
}

- (void)pointSizeWithSize:(CGFloat)size {
    pointSize = size;
}

- (void)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    components[0] = red;
    components[1] = green;
    components[2] = blue;
    components[3] = alpha;
}

- (void)doPaintingAction {
    
    float scale = self.drawingView.kTextureScale;
    
	GLfloat radius = pointSize * scale * 2;
    
    glPointSize(radius);
    
    BOOL isErasing = (components[0] == 1.0 && components[1] == 1.0 && components[2] == 1.0 && components[3] == 0.0);
    if (isErasing) {
        glBlendFuncSeparateOES(GL_ONE, GL_ZERO, GL_ONE, GL_ZERO);
    }
    
    glColor4f(components[0], components[1], components[2], components[3]);
    [self.drawingView setCurrentColorComponentWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
    
    glDisable(GL_TEXTURE_2D);
    
    CGPoint start = startPoint;
    CGPoint end = endPoint;
    
    start.x = start.x * scale; start.y = start.y * scale;
	end.x = end.x * scale; end.y = end.y * scale;
	
	NSUInteger	i, count;
	
	// Add points to the buffer so there are drawing points every X pixels
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / 1), 1);
    GLfloat xstep = (end.x - start.x)/(GLfloat)count;
    GLfloat ystep = (end.y - start.y)/(GLfloat)count;
    GLfloat	xOffset = start.x;
    GLfloat	yOffset = start.y;
    
    GLfloat vertices[count*2];
    
	for (i = 0; i < count; ++i) {
        vertices[i*2] = xOffset;
        vertices[i*2+1] = yOffset;
        
        xOffset += xstep;
        yOffset += ystep;
	}
    
    glVertexPointer(2, GL_FLOAT, 0, &vertices);
    glDrawArrays(GL_POINTS, 0, count);
    
    if (isErasing) {
        glBlendFuncSeparateOES(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
    }
    
    glEnable(GL_TEXTURE_2D);
}

@end
