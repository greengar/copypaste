//
//  ImageElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "ImageElement.h"
#import "NSData+WBBase64.h"

@interface ImageElement()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ImageElement
@synthesize imageView = _imageView;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {
        self.userInteractionEnabled = YES;
        
        UIImage *image = nil;
        NSString *imageString = [dictionary objectForKey:@"element_background"];
        if (imageString) {
            NSData *imageData = [NSData wbDataFromBase64String:imageString];
            image = [UIImage imageWithData:imageData];
        }
        [self initImageViewWithFrame:self.defaultFrame
                               image:image];
    }
    return self;
}

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

- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToDict]];
    [dict setObject:@"ImageElement" forKey:@"element_type"];
    if (self.imageView && self.imageView.image) {
        NSData *data = UIImagePNGRepresentation(self.imageView.image);
        [dict setObject:[data wbBase64EncodedString] forKey:@"element_image"];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    ImageElement *imageElement = [[ImageElement alloc] initWithDict:dictionary];
    return imageElement;
}

@end
