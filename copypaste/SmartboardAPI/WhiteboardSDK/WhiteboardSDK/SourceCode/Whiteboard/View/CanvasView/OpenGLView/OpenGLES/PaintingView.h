/*
 
 File: PaintingView.h
 Abstract: The class responsible for the rendering.
 
 */

//#import "EAGLView.h"
#import "FB2GLView.h"
#import "PaintingManager.h"
#import <QuartzCore/QuartzCore.h>

#define ENABLE_TEXT 0

#define kBrushPixelStep			1.0
#define kBrushPixelStepLite		3.0
#define kNotifUpdateLayerPreview @"kNotifUpdateLayerPreview"

/** @typedef ccDeviceOrientation
 Possible device orientations
 */
typedef enum {
	/// Device oriented vertically, home button on the bottom
	kCCDeviceOrientationPortrait = UIDeviceOrientationPortrait,	
	/// Device oriented vertically, home button on the top
    kCCDeviceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
	/// Device oriented horizontally, home button on the right
    kCCDeviceOrientationLandscapeLeft = UIDeviceOrientationLandscapeLeft,
	/// Device oriented horizontally, home button on the left
    kCCDeviceOrientationLandscapeRight = UIDeviceOrientationLandscapeRight,
	
	// Backward compatibility stuff
	CCDeviceOrientationPortrait = kCCDeviceOrientationPortrait,
	CCDeviceOrientationPortraitUpsideDown = kCCDeviceOrientationPortraitUpsideDown,
	CCDeviceOrientationLandscapeLeft = kCCDeviceOrientationLandscapeLeft,
	CCDeviceOrientationLandscapeRight = kCCDeviceOrientationLandscapeRight,
} ccDeviceOrientation;

@class GSMutableDictionary;

typedef struct {
	GLfloat x,y,z;
} recVec;

//KONG: pan & zoom
typedef struct {
    // View position
	GLfloat x; 
    GLfloat y; 
	GLfloat zoom; 
} Transforms;

@interface PaintingView : FB2GLView <PaintingManagerDelegate>
{
	GLuint			    brushTexture;
	GLuint				drawingTexture;
	GLuint				drawingFramebuffer;
	
	GLuint              textureId;
	
	/* screen, different than surface size */
	CGSize	screenSize_;
	
	/* screen, different than surface size */
	CGSize	surfaceSize_;
	
	/* content scale factor */
	CGFloat	contentScaleFactor_;
	
	/* contentScaleFactor could be simulated */
	BOOL	isContentScaleSupported_;
	
	// Fix ratio from iPhone to iPad
	BOOL isImageSent;
    
    // pan/zoom handling
	Transforms internal_transforms;
    CGFloat _lastZoom;
    
    //KONG: when the app goes background, but still receiving drawing messages from method stack.
    // we want to prevent GPU access in this case
    BOOL _isInBackground;
#define not_run_when_in_background if (_isInBackground) { return; }
    
    BOOL isExternal;
}

@property (nonatomic) BOOL isExternal;
@property (nonatomic) Transforms internal_transforms;
@property (nonatomic) BOOL isImageSent;
@property (nonatomic) float scaleFact;

/* Hector: use this if you want to calculate the bounding of your touches
 @property (nonatomic) CGPoint topLeftBounding;
 @property (nonatomic) CGPoint bottomRightBounding;
 @property (nonatomic) CGRect previewAreaRect;
 */

- (void)erase;
- (void)applyColorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
           strokeSize:(float)strokeSize;
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer isErasing:(BOOL)isErasing;
- (GLuint)loadTextureFromBuffer:(void*)buffer width:(int)width height:(int)height;

- (BOOL)loadImage:(CGImageRef)image;
- (BOOL)loadImageWithUIImage:(UIImage *)image sendViaHexString:(BOOL)hexOkay;
- (BOOL)loadRemoteImageWithHexString:(NSString*)imageHexString;
- (bool)loadTexture:(NSString *)texturePath;
- (void)drawObject;

- (UIImage *)captureToSavedPhotoAlbum;
- (void)captureToWhiteboardTempFile;
- (BOOL)loadFromSavedPhotoAlbum:(UIImage*)image;
- (CGImageRef)glToCGImageCreate;
- (UIImage *)glToUIImage;
- (CGImageRef)glToRotated90CGImageCreate;
- (UIImage *)glToRotated90UIImage;

- (void)renderImage;
- (void)transferImage:(UIImage *)image;
- (UIImage *)imageForTransferringFromImage:(UIImage *)image;

- (CGPoint)convertToGL:(CGPoint)uiPoint;
- (CGPoint)oppositeWithConvertToGL:(CGPoint)uiPoint;

- (id)initWithFrame:(CGRect)frame sharegroupView:(EAGLView *)glView;
- (void)drawView;
- (void)resetTransforms;
- (void)setToCurrentContext;

- (void)didEnterBackground;
- (void)willEnterForeground;

- (GLuint)copyTexture:(GLuint)nTexID_in width:(GLint)width height:(GLint)height;
- (void)drawTexture:(GLuint)textureID;

- (void)drawViewNoExternal;
- (void)addCurrentImageToUndoRedoSpace;

/* Hector: use this if you want to calculate the bounding of your touches
 - (void)calculateBounderFromPoint:(CGPoint)start toPoint:(CGPoint)end;
 */

@end