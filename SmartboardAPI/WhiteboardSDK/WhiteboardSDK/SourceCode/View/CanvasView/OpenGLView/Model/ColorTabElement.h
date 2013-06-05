//
//  ColorTabElement.h
// WhiteboardSDK
//
//  Created by Hector Zhao on 7/13/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorTabElement : NSObject {
    float       pointSize;
    float       opacity;
    UIColor     *tabColor;
    float       offsetXOnSpectrum;
    float       offsetYOnSpectrum;
}

- (id)initWithPointSize:(float)newPointSize opacity:(float)newOpacity color:(UIColor *)newColor;

@property (nonatomic)           float       pointSize;
@property (nonatomic)           float       opacity;
@property (nonatomic, retain)   UIColor     *tabColor;
@property (nonatomic)           float       offsetXOnSpectrum;
@property (nonatomic)           float       offsetYOnSpectrum;

@end
