//
//  ImageElement.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBaseElement.h"
#import "MainPaintingView.h"

@interface ImageElement : WBBaseElement <MainPaintViewDelegate>

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end
