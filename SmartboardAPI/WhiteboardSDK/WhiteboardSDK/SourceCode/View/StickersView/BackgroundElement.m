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

@interface BackgroundElement()
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation BackgroundElement
@synthesize backgroundView = _backgroundView;

- (id)initWithDict:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {
        self.userInteractionEnabled = YES;
        self.allowToSelect = YES;
        self.allowToMove = NO;
        self.allowToEdit = NO;
        self.layer.borderWidth = 0;
        
        UIImage *image = nil;
        NSString *imageString = [dictionary objectForKey:@"element_background"];
        if (imageString) {
            NSData *imageData = [NSData wbDataFromBase64String:imageString];
            image = [UIImage imageWithData:imageData];
        }
        [self initBackgroundViewWithFrame:self.defaultFrame
                                    image:image];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.allowToSelect = YES;
        self.allowToMove = NO;
        self.allowToEdit = NO;
        self.layer.borderWidth = 0;
        
        [self initBackgroundViewWithFrame:frame
                                    image:image];
    }
    return self;
}

- (void)initBackgroundViewWithFrame:(CGRect)frame image:(UIImage *)image {
    if (image) {
        self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.backgroundView setUserInteractionEnabled:YES];
        [self.backgroundView setContentMode:UIViewContentModeScaleToFill];
        [self.backgroundView setImage:image];
        [self addSubview:self.backgroundView];
    }
}


- (UIView *)contentView {
    return self.backgroundView;
}

- (void)select {
    // I'm background, I do nothing
}

- (void)deselect {
    // I'm background, I do nothing
}

- (NSMutableDictionary *)saveToDict {
    NSMutableDictionary *dict = [super saveToDict];
    [dict setObject:@"BackgroundElement" forKey:@"element_type"];
    if (self.backgroundView && self.backgroundView.image) {
        NSData *data = UIImagePNGRepresentation(self.backgroundView.image);
        [dict setObject:[data wbBase64EncodedString] forKey:@"element_background"];
    }
    return dict;
}

+ (WBBaseElement *)loadFromDict:(NSDictionary *)dictionary {
    BackgroundElement *bgElement = [[BackgroundElement alloc] initWithDict:dictionary];
    return bgElement;
}

@end
