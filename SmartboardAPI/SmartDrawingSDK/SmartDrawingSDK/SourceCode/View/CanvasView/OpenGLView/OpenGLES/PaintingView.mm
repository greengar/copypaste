/*
 
 File: PaintingView.m
 Abstract: The class responsible for the finger painting.
 
 */

#import "PaintingView.h"
#import "ImageManipulation.h"
#import "CGPointExtension.h"
#import "MainPaintingView.h"

#define MAX_FILTER_RADIUS 2

// Fix ratio from iPhone to ipad
#define iPhoneAndiPadWidthDifferences (768 - (320 * 2)) / 2
#define iPhoneAndiPadHeightDifferences (1024 - (460 * 2)) / 2

@implementation PaintingView
@synthesize isExternal;
@synthesize internal_transforms;
@synthesize isImageSent;

#pragma mark - Painting Manager delegates
- (void) colorChanged:(CGFloat *)color isSelf:(BOOL)is {

    if(is) {
        if (self.context) {
            [EAGLContext setCurrentContext:self.context];
            glColor4f(color[0], color[1], color[2], color[3]);
            [self setCurrentColorComponentWithRed:color[0] green:color[1] blue:color[2] alpha:color[3]];
        }
    } else {
        
    }
}

- (void) pointSizeChanged:(CGFloat)pointSize isSelf:(BOOL)is {
    
    if(is) {
        [EAGLContext setCurrentContext:self.context];
        //    [self setOffscreenFramebuffer];
        float scale = self.kTextureScale;
        if (isExternal) {
            scale = 1.0;
        }
        
        GLfloat radius = pointSize * scale * 2;
        glPointSize(radius);
        
    } else {
        
    }
}

#pragma mark - OpenGLES Set up
- (void) updateContentScaleFactor {
	EAGLView	*openGLView_ = self;
	
	// Based on code snippet from: http://developer.apple.com/iphone/prerelease/library/snippets/sp2010/sp28.html
	if ([openGLView_ respondsToSelector:@selector(setContentScaleFactor:)])
	{
		[openGLView_ setContentScaleFactor: contentScaleFactor_];
		
		isContentScaleSupported_ = YES;
		// DLog(@"contentScaleFactor_ = %f", contentScaleFactor_);
	}
	else
	{
		DLog(@"cocos2d: WARNING: calling setContentScaleFactor on iOS < 4. Using fallback mechanism");
		/* on pre-4.0 iOS, use bounds/transform */
		openGLView_.bounds = CGRectMake(0, 0,
										openGLView_.bounds.size.width * contentScaleFactor_,
										openGLView_.bounds.size.height * contentScaleFactor_);
		openGLView_.transform = CGAffineTransformScale(openGLView_.transform, 1 / contentScaleFactor_, 1 / contentScaleFactor_); 
		
		isContentScaleSupported_ = NO;
	}
}

- (void) setContentScaleFactor:(CGFloat)scaleFactor
{
	EAGLView	*openGLView_ = self;
	
	if( scaleFactor != contentScaleFactor_ ) {
		// for debugging
		//DLog(@"scaleFactor = %f | contentScaleFactor_ = %f", scaleFactor, contentScaleFactor_);
		contentScaleFactor_ = scaleFactor;
		surfaceSize_ = CGSizeMake( screenSize_.width * scaleFactor, screenSize_.height * scaleFactor );
		
		if( openGLView_ )
			[self updateContentScaleFactor];
		
	}
}

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext {
    self = [super initWithFrame:frame];
    if (self) {        
        //KONG: calculate scale due to RETINA display
        float scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1;
        
		//if( scale != 1 ) // BUG
		[self setContentScaleFactor:scale];
        
        if (!aContext)
            DLog(@"Failed to create ES context");
        else if (![EAGLContext setCurrentContext:aContext])
            DLog(@"Failed to set ES context current");
        
        [self setFramebuffer];        
        [self setTextureScale:scale];
        [self setOffscreenFramebuffer]; 
        
        [self setContext:aContext];
        [self resetTransforms];
		
		// Fix ratio from iPhone to iPad
		isImageSent = FALSE;
        
		// Set size
		screenSize_ = [self bounds].size;
		surfaceSize_ = CGSizeMake(screenSize_.width * contentScaleFactor_, screenSize_.height *contentScaleFactor_);
        
        // Set up OpenGL states
		glDisable(GL_DITHER);
		glMatrixMode(GL_MODELVIEW);
        
        glClearColor(1.0, 1.0, 1.0, 1.0);
        
        [[PaintingManager sharedManager] registerCallback:self];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    self = [self initWithFrame:frame context:aContext];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame sharegroupView:(EAGLView *)glView {
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1
                                                  sharegroup:glView.context.sharegroup];
    self = [self initWithFrame:frame context:aContext];
    if (self) {
    }
    
    return self;
}

// Releases resources when they are not longer needed.
- (void) dealloc
{
	[self setToCurrentContext];
    
    [[PaintingManager sharedManager] removeCallback:self];
	
//	glDeleteFramebuffersOES(1, &drawingFramebuffer);
//	glDeleteTextures(1, &drawingTexture);
}

#pragma mark - Clean the Canvas
// Erases the screen
- (void)erase {
    not_run_when_in_background
	[super erase];
    
	// Display the buffer
	[self drawView];
}

#pragma mark - Saving OpenGL ES Content
void releaseScreenshotData(void *info, const void *data, size_t size) {
	free((void *)data);
};

#pragma mark - Extract Canvas to Image
- (CGImageRef)glToCGImageCreate {
    
	int backingWidth  = self.kTextureDisplaySizeWidth;
	int backingHeight = self.kTextureDisplaySizeHeight;

    [self drawView];    

    GLuint tempFrameBuffer = [self copyAllLayerContentToFrameBuffer:kTextureOriginalSize height:kTextureOriginalSize];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, tempFrameBuffer);
    
	NSInteger myDataLength = backingWidth * backingHeight * 4;
	
	// allocate array and read pixels into it.
	GLuint *buffer = (GLuint *) malloc(myDataLength);
	glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	
	// gl renders "upside down" so swap top to bottom into new array.
	int y;
	for(y = 0; y < backingHeight / 2; y++) {
		int x;
		for(x = 0; x < backingWidth; x++) {
			//Swap top and bottom bytes
			GLuint top = buffer[y * backingWidth + x];
			GLuint bottom = buffer[(backingHeight - 1 - y) * backingWidth + x];
			buffer[(backingHeight - 1 - y) * backingWidth + x] = top;
			buffer[y * backingWidth + x] = bottom;
		}
	}
	
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, releaseScreenshotData);
	
	// prep the ingredients
	const int bitsPerComponent = 8;
	const int bitsPerPixel = 4 * bitsPerComponent;
	const int bytesPerRow = 4 * backingWidth;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast;
	
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(backingWidth, backingHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent); // 320, 480
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        DLog(@"glGetError(): 3 %d", (int)err);

    glDeleteFramebuffersOES(1, &tempFrameBuffer);
//    free(buffer);
	return imageRef;
}

- (UIImage *)glToUIImage {
	CGImageRef imageRef = [self glToCGImageCreate];
	
	// then make the UIImage from that
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return myImage;
}

- (CGImageRef)glToRotated90CGImageCreate {
    return [self glToRotated90UIImage].CGImage;
}
- (UIImage *)glToRotated90UIImage {
    UIImage* image = [self glToUIImage];
    return rotateImage(image, UIImageOrientationLeft);
}

- (UIImage *)rotated90UIImageFrom:(UIImage *)origin {
    //UIImage* image = [self glToUIImage];
    return rotateImage(origin, UIImageOrientationLeft);
}

- (CGImageRef)rotated90CGImageCreateFrom:(CGImageRef)origin {
    UIImage *myImage = [UIImage imageWithCGImage:origin];
    return [self rotated90UIImageFrom:myImage].CGImage;
}

- (UIImage *)captureToSavedPhotoAlbum {
    UIImage *image = [self glToUIImage];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
	return image;
}

- (void)saveToPhotosApp:(CGImageRef)cgImage {
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)captureToWhiteboardTempFile {
    UIImage *image = [self glToUIImage];
	NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
	NSString * documentsDir = [NSSearchPathForDirectoriesInDomains(  NSDocumentDirectory
																   , NSUserDomainMask
																   , YES) objectAtIndex:0];
	NSString * filePath = [documentsDir stringByAppendingPathComponent:@"WhiteboardAutosaved.tmp"];
	[data writeToFile:filePath atomically:NO];
}

- (void)addCurrentImageToUndoRedoSpace {
    
}

#pragma mark - Loading Images
- (BOOL)loadFromSavedPhotoAlbum:(UIImage*)image {
	
	if (!image)
		return NO;
	
	BOOL result = [self loadImageWithUIImage:image sendViaHexString:YES]; //USE_HEX_STRING_IMAGE_DATA
	
	if (!result) {
		DLog(@"FAILED: Image loading from saved photo album!");
	} else {
        [self drawObject];
    }
	
	return result;
}

- (void)renderImage {
	if(textureId) {
		DLog(@"Rendering image!");
		
		[self drawObject];
	}
	else DLog(@"No texture loaded!");
}

// Don't use loadTexture, use loadImage.  loadTexture requires the image dimensions to be a power of 2!!
- (bool)loadTexture:(NSString *)texturePath {
	
	CGImageRef image = [UIImage imageNamed:texturePath].CGImage;
	
	if( image )
	{
		size_t imageW = CGImageGetWidth( image );
		size_t imageH = CGImageGetHeight( image );
		
		GLubyte *textureData = (GLubyte *) malloc(imageW * imageH << 2);
		CGContextRef imageContext = CGBitmapContextCreate( textureData, imageW, imageH, 8, imageW << 2, CGImageGetColorSpace(image), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
		
		if( imageContext != NULL )
		{
			CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)imageW, (CGFloat)imageH), image);	
			
			[self loadTextureFromBuffer:textureData width:imageW height:imageH];
			
			CGContextRelease(imageContext);
		}
		
		
		free(textureData);
	}	
	
	return ( textureId != 0 );
}

- (BOOL)loadImageWithUIImage:(UIImage*)image sendViaHexString:(BOOL)hexOkay{
	
	// hexOkay is currently always YES, so this does not happen:
	//if(!hexOkay) [self loadImageWithUIImage:image];
	
	// DLog(@"Loading image with UIImage(W:%f  H:%f)!", image.size.width, image.size.height);
	
	// Prepare the image to be rendered on screen 
	//  First reset image orientation if needed
	if(image.imageOrientation != UIImageOrientationUp) {
		image = resetImageOrientation(image);
	} else {
        // DLog(@"Image orientation is already UP! (no changes)");
    }
	
	//  Second rotate image to best fit screen (portrait/landscape) if needed
	if (image.size.width > image.size.height) {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
            image = rotateImage(image, UIImageOrientationRight);
        } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            image = rotateImage(image, UIImageOrientationLeft);
        }
		
	} else {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
            image = rotateImage(image, UIImageOrientationDown);
        }
        //DLog(@"Image does not need to be rotated");
    }
	
	//  Third scale image to fit screen
	
	BOOL successful = [self loadImage:image.CGImage];
	
	return successful;
	
}

- (void)transferImage:(UIImage *)image {
    
}

- (UIImage *) imageForTransferringFromImage:(UIImage *)image {
    UIImage *imageForTransferring;
    if (IS_IPAD3) {
        // if it's ipad3, reduce size when sending out image.
        // because image taken in iPad 3 is way too big for other devices
        imageForTransferring = scaleImage(image, 768, 1024);
        
    } else {
        imageForTransferring = image;
    }
    
    return imageForTransferring;
}

- (GLuint)loadTextureFromBuffer:(void*)buffer width:(int)width height:(int)height {
    //	[self setOffscreenFramebuffer];
    
	
	if (!textureId)
		glGenTextures(1, &textureId);
	
	glLoadIdentity();
    
    // DLog(@"selfFrameWidth: %f", self.frame.size.width);
    
    //	glTranslatef((screenWidth / 2.0f) - width / 2.0f, (screenHeight / 2.0f) - height / 2.0f, 0.0f); // kColorPickerHeight
    glTranslatef((self.kTextureDisplaySizeWidth / 2.0f) - width / 2.0f, (self.kTextureDisplaySizeHeight / 2.0f) - height / 2.0f, 0.0f); // kColorPickerHeight
	
	glBindTexture(GL_TEXTURE_2D, textureId);
	
	// when texture area is small, bilinear filter the closest mipmap
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR  );
	// when texture area is large, bilinear filter the original
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	
	// the texture wraps over at the edges (repeat)
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
    
    size_t picSize = self.kTextureOriginalSize;
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, picSize, picSize, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) { // Error uploading texture. glError: 0x0501
		//DLog(@"Error uploading texture. glError: 0x%04X", err);
	}
    
    return textureId;
}

// this is used:
- (BOOL)loadImage:(CGImageRef)image {
    glLoadIdentity();
    [self setFramebuffer];
    
	if(image) {
		
		float scale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1;
		
		size_t imageW = self.bounds.size.width * scale;
		size_t imageH = self.bounds.size.height * scale;
		
		DLog(@"load Image size: %lo %lo", imageW, imageH);
		
		GLubyte *textureData = (GLubyte *) malloc(imageW * imageH << 2);
		
		if (textureData == nil) {
			DLog(@"Error: textureData == nil");
		}
		
		// CGContextRef imageContext = CGBitmapContextCreate( textureData, imageW, imageH, 8, imageW << 2, CGImageGetColorSpace(image), kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big );	
		CGContextRef imageContext = CGBitmapContextCreate( textureData, imageW, imageH, 8, imageW << 2 /* 2048 */, CGImageGetColorSpace(image), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast );
		CGContextSaveGState(imageContext);  

        CGContextSetFillColorWithColor(imageContext, [UIColor whiteColor].CGColor);
        CGContextFillRect(imageContext, CGRectMake(0, 0, imageW, imageH));

		if( imageContext != NULL )
		{
			// Fix ratio from iPhone to iPad
			if ([[PaintingManager sharedManager] getDeviceOf:kCollaborator] == iPhoneDevice && IS_IPAD && isImageSent) {
				CGContextTranslateCTM(imageContext, 0, imageH);
				CGContextScaleCTM(imageContext, 1.0*scale, -1.04*scale);
                
                // 64 = (768-640)/2
                // 32 = (1024-960)/2
				CGContextDrawImage(imageContext, CGRectMake(64, 32, 640, 920), image);
				
				[self loadTextureFromBuffer:textureData width:imageW height:imageH];
				CGContextRestoreGState(imageContext);  
				CGContextRelease(imageContext);
				free(textureData);
				return ( textureId != 0 );
                
			}
            
            // Fix ratio from iPhone5 to iPad
			if ([[PaintingManager sharedManager] getDeviceOf:kCollaborator] == iPhone5Device && IS_IPAD && isImageSent) {
				CGContextTranslateCTM(imageContext, 0, imageH);
				CGContextScaleCTM(imageContext, 1.0*scale, -1.04*scale);
                
                // 640x1136 -> 578x1024
                // 95 = (768-578)/2
                // 0  = (1024-1024)/2
				CGContextDrawImage(imageContext, CGRectMake(95, 0, 578, 1024), image);
				
				[self loadTextureFromBuffer:textureData width:imageW height:imageH];
				CGContextRestoreGState(imageContext);
				CGContextRelease(imageContext);
				free(textureData);
				return ( textureId != 0 );
                
			}
            
			// Fix ratio from iPad to iPhone #RETINA and #NOT RETINA and iPhone5
			if ([[PaintingManager sharedManager] getDeviceOf:kCollaborator] == iPadDevice && !IS_IPAD && isImageSent) {
				CGContextTranslateCTM(imageContext, 0, imageH);
				CGContextScaleCTM(imageContext, 1.0, -1.0);
				CGFloat xOffset;
				CGFloat yOffset; 
				CGFloat width;
				CGFloat height;
                
                if (IS_IPHONE5) {
                    xOffset = 48 * scale;   // 640x1136 -> 578x1024 -> 48 = (768-578)/2
                    yOffset = 0 * scale;
                    width = 426 * scale;    // 426 = (768*1136/1024)/2
                    height = 568 * scale;   // 568 = 1136/2
                } else {
                    xOffset = 32 * scale;
                    yOffset = 16 * scale;
                    width = 384 * scale;
                    height = 512 * scale;
                }
                
				CGContextDrawImage(imageContext, CGRectMake(-xOffset, -yOffset, width, height), image);
				
				[self loadTextureFromBuffer:textureData width:imageW height:imageH];
				CGContextRestoreGState(imageContext);  
				CGContextRelease(imageContext);
				free(textureData);
				return ( textureId != 0 );
			}
            
            // Fix ratio from iPhone5 to iPhone
			if ([[PaintingManager sharedManager] getDeviceOf:kCollaborator] == iPhone5Device && !IS_IPAD && !IS_IPHONE5 && isImageSent) {
				CGContextTranslateCTM(imageContext, 0, imageH);
				CGContextScaleCTM(imageContext, 1.0, -1.0);
				CGFloat xOffset = 0 * scale;
				CGFloat yOffset = 44 * scale; // 44 = (568-480)/2
				CGFloat width = 320 * scale;
				CGFloat height = 568 * scale;
				CGContextDrawImage(imageContext, CGRectMake(-xOffset, -yOffset, width, height), image);
				
				[self loadTextureFromBuffer:textureData width:imageW height:imageH];
				CGContextRestoreGState(imageContext);
				CGContextRelease(imageContext);
				free(textureData);
				return ( textureId != 0 );
			}
            
            // Fix ratio from iPhone to iPhone5
			if ([[PaintingManager sharedManager] getDeviceOf:kCollaborator] == iPhoneDevice && !IS_IPAD && IS_IPHONE5 && isImageSent) {
				CGContextTranslateCTM(imageContext, 0, imageH);
				CGContextScaleCTM(imageContext, 1.0, -1.0);
				CGFloat xOffset = 0 * scale;
				CGFloat yOffset = 44 * scale; // 44 = (568-480)/2
				CGFloat width = 320 * scale;
				CGFloat height = 480 * scale;
				CGContextDrawImage(imageContext, CGRectMake(xOffset, yOffset, width, height), image);
				
				[self loadTextureFromBuffer:textureData width:imageW height:imageH];
				CGContextRestoreGState(imageContext);
				CGContextRelease(imageContext);
				free(textureData);
				return ( textureId != 0 );
			}
            
			CGContextTranslateCTM(imageContext, 0, imageH);
			CGContextScaleCTM(imageContext, 1.0, -1.0);
			CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)imageW, (CGFloat)imageH), image);
			
			[self loadTextureFromBuffer:textureData width:imageW height:imageH];
			CGContextRestoreGState(imageContext);  
			CGContextRelease(imageContext);
		}
		
		free(textureData);
	}
	
    
    
	return (textureId != 0);
}

/*
 - (bool)releaseTexture {
 glDeleteTextures(1, textureId);
 }
 */

- (void) drawObject {
    [self drawTexture:textureId];
//    [(AppController*)[[UIApplication sharedApplication] delegate] setMyColor];    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifUpdateLayerPreview object:nil];
}


//KONG: draw a texture to offscreen FBO and render result
- (void)drawTexture:(GLuint)textureID {
    not_run_when_in_background
    
    [self setFramebuffer];
	[self setOffscreenFramebuffer];
    
    //	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    
    // Start drawing
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
    
    glLoadIdentity(); //Reset the matrix transformations     
    
	glBindTexture(GL_TEXTURE_2D, textureID);
    
	glVertexPointer(2, GL_FLOAT, 0, quatVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoord);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glLoadIdentity(); //Reset the matrix transformations     
    
    [self drawView];    
    
}

// moved from PaintingView.m
-(BOOL)loadRemoteImageWithHexString:(NSString*)imageHexString {
	if (_isInBackground) { return NO; }
	
	//Write to file to check hex data
	//[imageHexString writeToFile:[NSString stringWithFormat:@"%@/receive.txt", getDocumentPath()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	BOOL successful = NO;
	
	//RECEIVING END CODE:
	//Receiving user would receive the hex string and decode it using the following: 
	
	DLog(@"Loading remote image hex data");
	//DLog(@"Image Hex Data: %@", imageHexString);
	DLog(@"Image Hex String Length: %d", [imageHexString length]);
	
	if ([imageHexString length] % 2) {
		DLog(@"App Delegate - Image Transfer Fail: Unsuccessful image to byte conversion!");
		successful = NO;
	} else {
		int idx = 0; //index of the hex string char
		int len = [imageHexString length]; //length of the hex string
		
		//Create an array of bytes to store the hex values of the hex string (2 hex digits = 1 byte!)
		Byte *dataBytes = (Byte*)malloc(len/2+1); //Byte dataBytes[len/2]; //Don't know what len is, so better to malloc
		if(!dataBytes) { //Pointer is nil, meaning no memory to allocate!
			successful = NO;
		} else {
			//Memory allocated			
			dataBytes[len/2] = '\0';
			
			//Begin the conversion of hex string to actual hex value:
			while(idx < len){
				dataBytes[idx/2] = hexCharsToByteValue([imageHexString characterAtIndex:idx], [imageHexString characterAtIndex:idx+1]);
				idx += 2;
			}
			NSData *imageData =  [[NSData alloc] initWithBytes:dataBytes length:len/2];
			DLog(@"Image hex to data converted successfully! (Data Bytes: %d)", [imageData length]);
			
			
			//Raw NSData description for receive
			//[[imageData description] writeToFile:[NSString stringWithFormat:@"%@/raw_receive.txt", getDocumentPath()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
			
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            if(image) {
                DLog(@"UIImage conversion okay! W:%f  H:%f", image.size.width, image.size.height);
                
                // Fix ratio from iPhone to iPad
                isImageSent = TRUE;
                successful = [self loadImage:image.CGImage];
                isImageSent = FALSE;
                if(successful){
                    DLog(@"Remote Image Loaded Successfully!!");
                    [self drawObject];
//                    TODO: fix this
//                    if (UIAppDelegate.drawingView.extDrawingView) {
//                        [UIAppDelegate.drawingView transferToPaintingView:UIAppDelegate.drawingView.extDrawingView];
//                    }
                    
//                    [(AppController*)[[UIApplication sharedApplication] delegate] setMyColor];
                    
                    // for VGA Out - Elliot
                    //			if ([self isKindOfClass:[MainPaintingView class]]) {
                    //				[self transferToPaintingView];
                    //			}
                    [self addCurrentImageToUndoRedoSpace];
                    successful = YES;
                    
                } else {
                    DLog(@"Remote Image Loading failed!");
                }
            } else {
                DLog(@"UIImage conversion failed!");
            }			
			
			free(dataBytes);
		}
		
	}
	
	return successful;
}

#pragma mark - A simple version of convertToGL: for Whiteboard
-(CGPoint)convertToGL:(CGPoint)uiPoint {
	CGSize s = screenSize_;
	float newY = s.height - uiPoint.y;
    //	float newX = s.width - uiPoint.x;
	
	CGPoint ret;
    ret = ccp( uiPoint.x, newY );
	
	if( contentScaleFactor_ != 1 && isContentScaleSupported_ )
		ret = ccpMult(ret, contentScaleFactor_);
	return ret;
}

-(CGPoint)oppositeWithConvertToGL:(CGPoint)uiPoint {
    
    CGPoint ret;
    ret = ccp( uiPoint.x, uiPoint.y );
	if( contentScaleFactor_ != 1 && isContentScaleSupported_ ) {        
        CGFloat scaleOff = (CGFloat) 1.0f/contentScaleFactor_;
		ret = ccpMult(ret, scaleOff);
    }
    
	CGSize s = screenSize_;
	float newY = s.height - ret.y;
    ret = ccp( ret.x, newY );
    
	return ret;
}

#pragma mark - Offscreen Frame Buffer
- (void)setToCurrentContext {
    not_run_when_in_background
    [EAGLContext setCurrentContext:self.context];
}

- (void)drawViewNoExternal {
    if ([NSThread isMainThread] == NO) {
        DLog(@"WARNING: run drawView NOT in MainThread");
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
    }
    
    //    DLog(@"drawView");
    GLenum err;
    
    [self setFramebuffer];
    glLoadIdentity();
    glPushMatrix();
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glTranslatef(internal_transforms.x * 2/screenSize_.width, - internal_transforms.y * 2/screenSize_.height, 0);
	glScalef(internal_transforms.zoom, internal_transforms.zoom, 1.0);    
    
    [self renderOffscreenTexture:NO];
    
    [self presentFramebuffer];
    glPopMatrix();    
    // use pushMatrix/popMatrix or 
    // glLoadIdentity here. haven't tried to see which one is faster
    
    err = glGetError();
    if (err != GL_NO_ERROR) {
        DLog(@"glGetError(): 10 %d", (int)err);
    }
}

- (void)drawView {
    not_run_when_in_background
    
    if ([NSThread isMainThread] == NO) {
        DLog(@"WARNING: run drawView NOT in MainThread");
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
    }
    
    //    DLog(@"drawView");
    GLenum err;
    
    [self setFramebuffer];
    glLoadIdentity();
    glPushMatrix();

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glTranslatef(internal_transforms.x * 2/screenSize_.width, - internal_transforms.y * 2/screenSize_.height, 0);
	glScalef(internal_transforms.zoom, internal_transforms.zoom, 1.0);    
    
    [self renderOffscreenTexture:NO];
    
    [self presentFramebuffer];
    glPopMatrix();    
    // use pushMatrix/popMatrix or 
    // glLoadIdentity here. haven't tried to see which one is faster
    
    err = glGetError();
    if (err != GL_NO_ERROR)
        DLog(@"glGetError(): 10 %d", (int)err);
}

- (void)applyColorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha strokeSize:(float)strokeSize {
    
}

// Drawings a line onscreen based on where the user touches
- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end toURBackBuffer:(BOOL)toURBackBuffer isErasing:(BOOL)isErasing {
    not_run_when_in_background
    
    if (!toURBackBuffer) {
        [self setOffscreenFramebuffer];
    }
    glDisable(GL_TEXTURE_2D);
    
    if (isErasing) {
//        glEnable(GL_BLEND);
        glBlendFuncSeparateOES(GL_ONE, GL_ZERO, GL_ONE, GL_ZERO);
    } 
    
    float scale = self.kTextureScale;
    
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
    
	for(i = 0; i < count; ++i) {
        
//        xOffset = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
//        yOffset = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        
        vertices[i*2] = xOffset;
        vertices[i*2+1] = yOffset;    
        
        xOffset += xstep;
        yOffset += ystep;
	}
    
    glVertexPointer(2, GL_FLOAT, 0, &vertices);	
    glDrawArrays(GL_POINTS, 0, count);

    if (isErasing) {
//        glDisable(GL_BLEND);
        glBlendFuncSeparateOES(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
    }
    
    glEnable(GL_TEXTURE_2D);
    
    if (!toURBackBuffer) {
        [self drawViewNoExternal];
    }
}

//KONG: this method is used for testing
- (void)drawSomethingToOffscreenBuffer {
    [self setOffscreenFramebuffer];
    
    glColor4f(0, 0, 1, 0.5);
    [self renderLineFromPoint:CGPointMake(0.0, 0.0) toPoint:CGPointMake(160, 240) toURBackBuffer:NO isErasing:NO];
    
    glColor4f(0, 1, 1, 0.5);
    [self renderLineFromPoint:CGPointMake(160, 240) toPoint:CGPointMake(80, 360) toURBackBuffer:NO isErasing:NO];
    
    //    [self render1Point];
}

- (GLuint)copyTexture:(GLuint)nTexID_in width:(GLint)width height:(GLint)height {
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
    
    
    glBindTexture( GL_TEXTURE_2D , nTexID_in );
    
    
    // Start drawing
    GLfloat textureVertices[8] = {
        1.f, -1.f,
        1.f,  1.f,
        -1.f,  1.f,        
        -1.f, -1.f,        
	};
	
	GLfloat textureCoord[8] = { 
        1.f, 0.f,
        1.f,  1.f,
        0.f,  1.f,        
        0.f, 0.f,        
    };
    
    glDisable(GL_BLEND);
    
	glVertexPointer(2, GL_FLOAT, 0, textureVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoord);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glEnable(GL_BLEND);    
    
    
    
    // unbind texture and frame buffer
    glBindTexture( GL_TEXTURE_2D , 0 );
    glBindFramebufferOES( GL_FRAMEBUFFER_OES, 0 );
    glDeleteRenderbuffersOES(1, &nRbo);
    glDeleteFramebuffersOES( 1, &nFbo );
    
    
    // Restore the old view port
    //    glViewport( viewport[0],viewport[1],viewport[2],viewport[3]);
    
    return nTexID_out;
}

#pragma mark - Camera for Pan/Zoom
- (void)resetTransforms {
	internal_transforms.zoom = 1.0;
	internal_transforms.x = 0;
    internal_transforms.y = 0;
}

#pragma mark - Multitasking
- (void)didEnterBackground {
    _isInBackground = YES;
}

- (void)willEnterForeground {
    _isInBackground = NO;    
}

@end