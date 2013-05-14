//
//  CPUserView.m
//  copypaste
//
//  Created by Elliot Lee on 4/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPUserView.h"

#define kNameLabelHeight 23

@interface CPUserView ()

@property (nonatomic, strong) UIButton *pasteButton;
@property (nonatomic) CGRect originalFrame;
@end

@implementation CPUserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.avatarButton = [[EGOImageButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarButton.delegate = self;
        [self.avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.avatarButton];
        
        self.pasteButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                      self.avatarButton.frame.size.height,
                                                                      frame.size.width,
                                                                      frame.size.height - self.avatarButton.frame.size.height)];
        [self addSubview:self.pasteButton];
        
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingIndicator.center = self.avatarButton.center;
        [self.loadingIndicator startAnimating];
        [self addSubview:self.loadingIndicator];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, kNameLabelHeight)];
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor whiteColor]; // TODO: consider other colors
        self.nameLabel.font = DEFAULT_FONT_SIZE(11.0f);
        [self.nameLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.nameLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.4]];
        [self.pasteButton addSubview:self.nameLabel];
        
        [self.pasteButton setTitle:@"" forState:UIControlStateNormal];
        [self.pasteButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.pasteButton.titleLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.4]];
        [self.pasteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.pasteButton setTitleEdgeInsets:UIEdgeInsetsMake(kNameLabelHeight+5, 0, 0, 0)];
        [self.pasteButton addTarget:self action:@selector(pasteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.badgeView = [[MKNumberBadgeView alloc] init];
        [self.badgeView setFrame:CGRectMake(self.avatarButton.frame.origin.x,
                                            self.avatarButton.frame.origin.y,
                                            self.avatarButton.frame.size.width*2,
                                            self.avatarButton.frame.size.height*2)];
        [self.badgeView setValue:0];
        [self addSubview:self.badgeView];
        
        self.originalFrame = frame;
    }
    return self;
}

- (void)avatarButtonTapped:(id)sender
{
    if (self.user) {
        [self.delegate didTapAvatarUserView:self];
    }
}

- (void)pasteButtonTapped:(id)sender
{
    if (self.user) {
        [self.delegate didTapPasteUser:self.user];
    }
}

- (void)setIsLight:(BOOL)light
{
    _isLight = light;
    if (light)
    {
        [self.pasteButton setBackgroundImage:[UIImage imageNamed:@"pastebuttonlight.fw.png"] forState:UIControlStateNormal];
        self.backgroundColor = kCPLightOrangeColor;
    }
    else
    {
        [self.pasteButton setBackgroundImage:[UIImage imageNamed:@"pastebutton.fw.png"] forState:UIControlStateNormal];
        self.backgroundColor = kCPPasteTextColor;
    }
}

- (void)setUser:(CPUser *)user {
    if (_user && ![[_user uid] isEqualToString:[user uid]]) { // This user is a new one
        [self updateData:user];
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(self.originalFrame.origin.x,
                                    self.originalFrame.origin.y+self.originalFrame.size.height,
                                    self.originalFrame.size.width,
                                    self.originalFrame.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.frame = self.originalFrame;
            }];
        }];
    } else {
        [self updateData:user];
    }
}

- (void)updateData:(CPUser *)user {
    _user = user;
    if (user != nil) {
        if (user.isAvatarCached) {
            [self.avatarButton setImage:user.avatarImage forState:UIControlStateNormal];
        } else if (user.avatarURLString) {
            [self.avatarButton setImageURL:[NSURL URLWithString:user.avatarURLString]];
        } else {
            [self.avatarButton setImage:nil forState:UIControlStateNormal];
        }
        
        [self.loadingIndicator stopAnimating];
        [self.avatarButton setBackgroundImage:[UIImage imageNamed:@"default_avatar.png"] forState:UIControlStateNormal];
        [self.pasteButton setTitle:@"paste" forState:UIControlStateNormal];
        self.nameLabel.text = [user displayName];
        self.badgeView.value = [user numOfUnreadMessage];
    }
}

#pragma mark - EGOImageButtonDelegate

- (void)imageButtonLoadedImage:(EGOImageButton*)imageButton {
    [imageButton setNeedsDisplay];
    self.user.avatarImage = imageButton.imageView.image;
    self.user.isAvatarCached = YES;
}

- (void)imageButtonFailedToLoadImage:(EGOImageButton*)imageButton error:(NSError*)error {
    [imageButton cancelImageLoad];
}

@end
