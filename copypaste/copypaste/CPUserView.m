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

@end

@implementation CPUserView

//@synthesize user = _user;
//@synthesize isLight = _isLight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.avatarButton = [[EGOImageButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        //contentView.clipsToBounds = YES;
        self.avatarButton.delegate = self;
        [self.avatarButton addTarget:self action:@selector(avatarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.avatarButton];
        
        self.pasteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.avatarButton.frame.size.height, frame.size.width, frame.size.height - self.avatarButton.frame.size.height)];
//        self.pasteButton.backgroundColor = [UIColor blueColor];
//        self.pasteButton.tag = index; // tag is used by -pasteToUserWithButton: to identify the user position
        // TODO: check -pasteToUserWithButton:
//        [self.pasteButton addTarget:self action:@selector(pasteToUserWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.pasteButton];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, kNameLabelHeight)];
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor whiteColor]; // TODO: consider other colors
        self.nameLabel.font = DEFAULT_FONT_SIZE(11.0f);
        [self.nameLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.nameLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.4]];
        [self.pasteButton addSubview:self.nameLabel];
        
        [self.pasteButton setTitle:@"paste" forState:UIControlStateNormal];
        [self.pasteButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [self.pasteButton.titleLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.4]];
        [self.pasteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.pasteButton setTitleEdgeInsets:UIEdgeInsetsMake(kNameLabelHeight+5, 0, 0, 0)];
        [self.pasteButton addTarget:self action:@selector(pasteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)avatarButtonTapped:(id)sender
{
    [self.delegate didTapAvatarUserView:self];
}

- (void)pasteButtonTapped:(id)sender
{
    [self.delegate didTapPasteUser:self.user];
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

//- (void)setBackgroundColor:(UIColor *)backgroundColor
//{
//    [super setBackgroundColor:backgroundColor];
//    self.pasteButton.backgroundColor = backgroundColor;
//}

- (void)setUser:(CPUser *)user
{
    _user = user;
    if (user != nil) {
        // TODO: animate if necessary
        
        if (user.isAvatarCached) {
            [self.avatarButton setImage:user.avatarImage forState:UIControlStateNormal];
        } else if (user.avatarURLString) {
            [self.avatarButton setImageURL:[NSURL URLWithString:user.avatarURLString]];
        }
        // If user creates a new account, fullname is the same as username
        // If user logs in with Facebook, fullname is the person's Full Name
        // (1) firstname (2) fullname (3) username
        // TODO: add/use firstname in User class
        // TODO: use displayName
        if (user.firstname)
            self.nameLabel.text = user.firstname;
        else if (user.fullname)
            self.nameLabel.text = user.fullname;
        else
            self.nameLabel.text = user.username;
    }
}

#pragma mark - EGOImageButtonDelegate

- (void)imageButtonLoadedImage:(EGOImageButton*)imageButton
{
    [imageButton setNeedsDisplay];
}

- (void)imageButtonFailedToLoadImage:(EGOImageButton*)imageButton error:(NSError*)error
{
    [imageButton cancelImageLoad];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
