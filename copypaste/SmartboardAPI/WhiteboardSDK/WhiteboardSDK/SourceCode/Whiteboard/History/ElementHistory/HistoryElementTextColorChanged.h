//
//  HistoryElementTextColorChanged.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/7/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElement.h"

@interface HistoryElementTextColorChanged : HistoryElement

@property (nonatomic, strong) UIColor *originalColor;
@property (nonatomic) float originalColorX;
@property (nonatomic) float originalColorY;
@property (nonatomic, strong) UIColor *changedColor;
@property (nonatomic) float changedColorX;
@property (nonatomic) float changedColorY;

@end
