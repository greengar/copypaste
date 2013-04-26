//
//  CPMessageView.m
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPMessageView.h"
#import <QuartzCore/QuartzCore.h>
#import "GSSession.h"

#define kOffset 6
#define kHeaderHeight 100
#define kButtonHeight 60
#define kAvatarSize 76
#define kLeftOffetForText kOffset+2+kAvatarSize+kOffset
#define kTextHeight 25

@implementation CPMessageView
@synthesize message = _message;
@synthesize userAvatarImageView = _userAvatarImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame message:(CPMessage *)message
{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = message;
        
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                         0,
                                                                                         frame.size.width,
                                                                                         frame.size.height)];
        if (IS_IPHONE5) {
            backgroundImageView.image = [UIImage imageNamed:@"background-548h.png"];
        } else {
            backgroundImageView.image = [UIImage imageNamed:@"background.png"];
        }
        backgroundImageView.backgroundColor = [UIColor whiteColor];
        backgroundImageView.layer.cornerRadius = 5;
        backgroundImageView.clipsToBounds = YES;
        [self addSubview:backgroundImageView];
        
        self.userAvatarImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(kOffset+2,
                                                                                  kOffset+2,
                                                                                  kAvatarSize,
                                                                                  kAvatarSize)];
        self.userAvatarImageView.backgroundColor = [UIColor grayColor];
        self.userAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.userAvatarImageView.layer.cornerRadius = 3;
        self.userAvatarImageView.clipsToBounds = YES;
        if (message.sender.isAvatarCached) {
            [self.userAvatarImageView setImage:message.sender.avatarImage];
        } else {
            [self.userAvatarImageView setImageURL:[NSURL URLWithString:message.sender.avatarURLString]];
            [self.userAvatarImageView setDelegate:self];
        }
        [self addSubview:self.userAvatarImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftOffetForText,
                                                                       kOffset,
                                                                       frame.size.width-kLeftOffetForText-kOffset,
                                                                       kTextHeight)];
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.font = DEFAULT_FONT_SIZE(15.0f);
        self.usernameLabel.textColor = [UIColor whiteColor];
        [self.usernameLabel setText:[NSString stringWithFormat:@"Sender: %@", message.sender.fullname]];
        [self addSubview:self.usernameLabel];
        
        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftOffetForText,
                                                                       kOffset+kTextHeight+kOffset,
                                                                       frame.size.width-kLeftOffetForText-kOffset,
                                                                       kTextHeight)];
        self.distanceLabel.backgroundColor = [UIColor clearColor];
        self.distanceLabel.font = DEFAULT_FONT_SIZE(15.0f);
        self.distanceLabel.textColor = [UIColor whiteColor];
        [self.distanceLabel setText:[NSString stringWithFormat:@"Distance: %@", [message.sender distanceStringToUser:[[GSSession activeSession] currentUser]]]];
        [self addSubview:self.distanceLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftOffetForText,
                                                                       kOffset+2*(kTextHeight+kOffset),
                                                                       frame.size.width-kLeftOffetForText-kOffset,
                                                                       kTextHeight)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = DEFAULT_FONT_SIZE(15.0f);
        self.timeLabel.textColor = [UIColor whiteColor];
        [self.timeLabel setText:[NSString stringWithFormat:@"Time: %@", [GSUtils dateDiffFromInterval:message.createdDateInterval]]];
        [self addSubview:self.timeLabel];
        
        UIImageView * pasteboardBackgroundImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(kOffset,
                                                      kHeaderHeight+kOffset,
                                                      frame.size.width-2*kOffset,
                                                      frame.size.height-2*kOffset-kHeaderHeight-kButtonHeight)];
        pasteboardBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                                        | UIViewAutoresizingFlexibleHeight;
        pasteboardBackgroundImageView.image = [[UIImage imageNamed:@"pasteboard.png"] stretchableImageWithLeftCapWidth:30
                                                                                                          topCapHeight:30];
        [self addSubview:pasteboardBackgroundImageView];
        
        // The "pasteboard" string content
        self.pasteboardTextView = [[CPTextView alloc] initWithFrame:CGRectMake(kOffset+2,
                                                                               kHeaderHeight+kOffset+2,
                                                                               frame.size.width-2*(kOffset+2),
                                                                               frame.size.height-2*(kOffset+2)-kHeaderHeight-kButtonHeight)];
        self.pasteboardTextView.backgroundColor = [UIColor clearColor];
        self.pasteboardTextView.textColor = [UIColor whiteColor];
        self.pasteboardTextView.textAlignment = UITextAlignmentCenter;
        self.pasteboardTextView.editable = NO;
        self.pasteboardTextView.font = DEFAULT_FONT_SIZE(16.0f);
        self.pasteboardTextView.hidden = YES;
        self.pasteboardTextView.layer.cornerRadius = 3;
        self.pasteboardTextView.clipsToBounds = YES;
        self.pasteboardTextView.delegate = self;
        self.pasteboardTextView.bounces = YES;
        self.pasteboardTextView.alwaysBounceVertical = YES;
        [self addSubview:self.pasteboardTextView];
        
        // The "pasteboard" image scroll view
        self.pasteboardImageHolderView = [[UIScrollView alloc] initWithFrame:CGRectMake(kOffset+2,
                                                                                        kHeaderHeight+kOffset+2,
                                                                                        frame.size.width-2*(kOffset+2),
                                                                                        frame.size.height-2*(kOffset+2)-kHeaderHeight-kButtonHeight)];
        self.pasteboardImageHolderView.backgroundColor = [UIColor clearColor];
        self.pasteboardImageHolderView.hidden = YES;
        self.pasteboardImageHolderView.layer.cornerRadius = 3;
        self.pasteboardImageHolderView.clipsToBounds = YES;
        self.pasteboardImageHolderView.delegate = self;
        [self addSubview:self.pasteboardImageHolderView];
        
        // The "pasteboard" image content
        self.pasteboardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 self.pasteboardImageHolderView.frame.size.width,
                                                                                 self.pasteboardImageHolderView.frame.size.height)];
        self.pasteboardImageView.backgroundColor = [UIColor clearColor];
        [self.pasteboardImageHolderView addSubview:self.pasteboardImageView];
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setFrame:CGRectMake(0, 400, 106, 60)];
        [self addSubview:saveButton];
        
        UIButton *remindMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [remindMeButton setTitle:@"Copy" forState:UIControlStateNormal];
        [remindMeButton addTarget:self action:@selector(copyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [remindMeButton setFrame:CGRectMake(107, 400, 106, 60)];
        [self addSubview:remindMeButton];
        
        UIButton *discardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [discardButton setTitle:@"Discard" forState:UIControlStateNormal];
        [discardButton addTarget:self action:@selector(discardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [discardButton setFrame:CGRectMake(214, 400, 106, 60)];
        [self addSubview:discardButton];
        
        // Update message content
        if ([message.messageContent isKindOfClass:[NSString class]]) {
            self.pasteboardTextView.hidden = NO;
            [self.pasteboardTextView setText:((NSString *)message.messageContent)];
            
        } else if ([message.messageContent isKindOfClass:[UIImage class]]) {
            self.pasteboardImageHolderView.hidden = NO;
            [self.pasteboardImageView setImage:((UIImage *) message.messageContent)];
            float imageWidth = ((UIImage *) message.messageContent).size.width;
            float imageHeight = ((UIImage *) message.messageContent).size.height*self.pasteboardImageHolderView.frame.size.height/imageWidth;
            self.pasteboardImageView.frame = CGRectMake(self.pasteboardImageView.frame.origin.x,
                                                        self.pasteboardImageView.frame.origin.y,
                                                        self.pasteboardImageView.frame.size.width,
                                                        imageHeight);
            self.pasteboardImageHolderView.contentSize = CGSizeMake(self.pasteboardImageHolderView.frame.size.width,
                                                                    imageHeight);
        }
    }
    return self;
}

- (void)showMeOnView:(UIView *)view {
    [view addSubview:self];
}

- (void)saveButtonTapped:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(saveMessage:)]) {
        [self.delegate saveMessage:self.message];
    }
}

- (void)copyButtonTapped:(id)sender {
    [self removeFromSuperview];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if ([self.message.messageContent isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *) self.message.messageContent;
        NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        [pasteboard setData:stringData forPasteboardType:@"public.text"];
        
    } else if ([self.message.messageContent isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *) self.message.messageContent;
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [pasteboard setData:imageData forPasteboardType:@"public.jpg"];
    }
    [pasteboard setPersistent:YES];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(copyMessage:)]) {
        [self.delegate copyMessage:self.message];
    }
}

- (void)discardButtonTapped:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(discardMessage:)]) {
        [self.delegate discardMessage:self.message];
    }
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}
@end
