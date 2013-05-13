//
//  CPUserView.h
//  copypaste
//
//  Created by Elliot Lee on 4/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "CPUser.h"
#import "MKNumberBadgeView.h"

@class CPUserView;

@protocol CPUserViewDelegate <NSObject>

- (void)didTapAvatarUserView:(CPUserView *)userView;
- (void)didTapPasteUser:(CPUser *)user;

@end

@interface CPUserView : UIView <EGOImageButtonDelegate>

@property (nonatomic, strong) CPUser *user;
@property (nonatomic, strong) EGOImageButton *avatarButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) MKNumberBadgeView *badgeView;
@property (nonatomic) BOOL isLight;
@property (nonatomic, weak) id<CPUserViewDelegate> delegate;

@end
