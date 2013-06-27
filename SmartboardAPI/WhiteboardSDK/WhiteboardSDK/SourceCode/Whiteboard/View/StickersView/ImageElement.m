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

@interface ImageElement()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ImageElement
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self initImageViewWithFrame:frame image:image];
    }
    return self;
}

- (void)initImageViewWithFrame:(CGRect)frame image:(UIImage *)image {
    if (image) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.imageView setUserInteractionEnabled:YES];
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
        [self.imageView setImage:image];
        [self addSubview:self.imageView];
    }
}

- (UIView *)contentView {
    return self.imageView;
}

- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToData]];
    [dict setObject:@"ImageElement" forKey:@"element_type"];
    if (self.imageView && self.imageView.image) {
        NSData *data = UIImagePNGRepresentation(self.imageView.image);
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

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.imageView = nil;
}

@end
