//
//  ImageElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "ImageElement.h"
#import "NSData+WBBase64.h"
#import "WBUtils.h"
#import "HistoryManager.h"
#import "HistoryElementCanvasDraw.h"

@interface ImageElement() {
    UIImageView *imageView;
    MainPaintingView *drawingView;
    UIImageView *screenshotImageView;
    NSString *currentBrushId;
}
@end

@implementation ImageElement

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        [self initImageViewWithFrame:frame
                               image:image];
        
        // OpenGL View
        drawingView = [[MainPaintingView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         frame.size.width,
                                                                         frame.size.height)];
        [self addSubview:drawingView];
        [drawingView setDelegate:self];
        [drawingView initialDrawing];
    }
    return self;
}

- (void)initImageViewWithFrame:(CGRect)frame image:(UIImage *)image {
    if (image) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [imageView setUserInteractionEnabled:YES];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [imageView setImage:image];
        [self addSubview:imageView];
    }
}

- (UIView *)contentView {
    return imageView;
}

- (UIView *)contentDrawingView {
    return drawingView;
}

- (void)scaleTo:(float)scale {
    [super scaleTo:scale];
    drawingView.scaleFact *= scale;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        [drawingView touchesCancelled:touches withEvent:event];
    }
}

- (void)resetDrawingViewTouches {
    [drawingView resetDrawingViewTouches];
}

#pragma marl - Screenshot
- (void)takeScreenshot {
    screenshotImageView = [[UIImageView alloc] initWithFrame:drawingView.frame];
    screenshotImageView.image = [drawingView glToUIImage];
    [self addSubview:screenshotImageView];
}

- (void)removeScreenshot {
    [screenshotImageView removeFromSuperview];
}

- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToData]];
    [dict setObject:@"ImageElement" forKey:@"element_type"];
    if (imageView && imageView.image) {
        NSData *data = UIImagePNGRepresentation(imageView.image);
        NSString *dataString = [data wbBase64EncodedString];
        int numOfElement = round((float)[dataString length]/(float)[WBUtils maxValueSize]);
        if (numOfElement > 1) { // More than 1 element
            NSMutableArray *elementArray = [NSMutableArray arrayWithCapacity:numOfElement];
            for (int i = 0; i < numOfElement; i++) {
                int location = [WBUtils maxValueSize]*i;
                int length = ([WBUtils maxValueSize] > ([dataString length]-location)
                              ? ([dataString length]-location)
                              : [WBUtils maxValueSize]);
                NSString *element = [dataString substringWithRange:NSMakeRange(location, length)];
                [elementArray addObject:element];
            }
            [dict setObject:elementArray forKey:@"element_background"];
            
        } else {
            [dict setObject:dataString forKey:@"element_background"];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)loadFromData:(NSDictionary *)elementData {
    [super loadFromData:elementData];
    
    UIImage *image = nil;
    NSObject *imageContent = [elementData objectForKey:@"element_background"];
    if (imageContent) {
        if ([imageContent isKindOfClass:[NSArray class]]) {
            NSMutableString *messageString = [NSMutableString new];
            for (int i = 0; i < [((NSArray *) imageContent) count]; i++) {
                [messageString appendString:[((NSArray *) imageContent) objectAtIndex:i]];
            }
            NSData *imageData = [NSData wbDataFromBase64String:messageString];
            image = [UIImage imageWithData:imageData];
            
        } else {
            NSData *imageData = [NSData wbDataFromBase64String:((NSString *)imageContent)];
            image = [UIImage imageWithData:imageData];
        }
    }
    
    [self initImageViewWithFrame:self.defaultFrame
                           image:image];

}

#pragma mark - Undo/Redo
- (void)pushedCommandToUndoStack:(PaintingCmd *)cmd {
    currentBrushId = [[HistoryManager sharedManager] addActionBrushElement:self
                                                                   forPage:(WBPage *)self.superview
                                                       withPaintingCommand:cmd
                                                                 withBlock:^(HistoryElementCanvasDraw *history, NSError *error) {}];
}

- (void)updatedCommandOnUndoStack:(PaintingCmd *)cmd {
    [[HistoryManager sharedManager] updateActionBrushElementWithId:currentBrushId
                                               withPaintingCommand:cmd
                                                           forPage:(WBPage *)self.superview
                                                         withBlock:^(HistoryElementCanvasDraw *history, NSError *error) {}];
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    drawingView = nil;
}

#pragma mark - Collaboration Back
- (void)didApplyColorRed:(float)red
                   green:(float)green
                    blue:(float)blue
                   alpha:(float)alpha
              strokeSize:(float)strokeSize {
    if ([self.delegate respondsToSelector:@selector(didApplyColorRed:green:blue:alpha:strokeSize:elementUid:)]) {
        [self.delegate didApplyColorRed:red
                                  green:green
                                   blue:blue
                                  alpha:alpha
                             strokeSize:strokeSize
                             elementUid:self.uid];
    }
}

- (void)didRenderLineFromPoint:(CGPoint)start
                       toPoint:(CGPoint)end
                toURBackBuffer:(BOOL)toURBackBuffer
                     isErasing:(BOOL)isErasing {
    if ([self.delegate respondsToSelector:@selector(didRenderLineFromPoint:toPoint:toURBackBuffer:isErasing:elementUid:)]) {
        [self.delegate didRenderLineFromPoint:start
                                      toPoint:end
                               toURBackBuffer:toURBackBuffer
                                    isErasing:isErasing
                                   elementUid:self.uid];
    }
}

#pragma mark - Collaboration Forward
- (void)applyColorRed:(float)red
                green:(float)green
                 blue:(float)blue
                alpha:(float)alpha
           strokeSize:(float)strokeSize {
    [drawingView applyColorRed:red
                         green:green
                          blue:blue
                         alpha:alpha
                    strokeSize:strokeSize];
}

- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer
                  isErasing:(BOOL)isErasing {
    [drawingView renderLineFromPoint:start
                             toPoint:end
                      toURBackBuffer:toURBackBuffer
                           isErasing:isErasing];
    
}

@end
