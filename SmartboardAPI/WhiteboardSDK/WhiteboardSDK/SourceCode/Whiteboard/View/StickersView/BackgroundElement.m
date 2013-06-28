//
//  BackgroundElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "BackgroundElement.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+WBBase64.h"
#import "WBUtils.h"

@interface BackgroundElement() {
    UIImageView *backgroundView;
}
@end

@implementation BackgroundElement

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        [self initBackgroundViewWithFrame:frame
                                    image:image];
    }
    return self;
}

- (void)initBackgroundViewWithFrame:(CGRect)frame image:(UIImage *)image {
    if (image) {
        backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [backgroundView setUserInteractionEnabled:YES];
        [backgroundView setContentMode:UIViewContentModeScaleToFill];
        [backgroundView setImage:image];
        [self addSubview:backgroundView];
    }
}


- (UIView *)contentView {
    return backgroundView;
}

- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"BackgroundElement" forKey:@"element_type"];
    if (backgroundView && backgroundView.image) {
        NSData *data = UIImagePNGRepresentation(backgroundView.image);
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
    return dict;
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
    
    [self initBackgroundViewWithFrame:self.defaultFrame
                                image:image];
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    backgroundView = nil;
}


@end
