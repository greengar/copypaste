//
//  CPMessageView.m
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPMessageView.h"
#import <QuartzCore/QuartzCore.h>
#import <Smartboard/Smartboard.h>

#define kOffset 6
#define kHeaderHeight kOffset+2+kAvatarSize+kOffset
#define kButtonHeight 60
#define kAvatarSize 76
#define kLeftOffetForText kOffset+2+kAvatarSize+kOffset
#define kTextHeight 25
#define kButtonHeight 60

@implementation CPMessageView
@synthesize message = _message;
@synthesize userAvatarImageView = _userAvatarImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize delegate = _delegate;
@synthesize viewController = _viewController;

- (id)initWithFrame:(CGRect)frame message:(CPMessage *)message controller:(UIViewController *)baseController {
    self = [super initWithFrame:frame];
    if (self) {
        self.message = message;
        self.baseViewController = baseController;
        
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        self.backgroundColor = kCPBackgroundColor;
        
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
        self.usernameLabel.textColor = [UIColor darkGrayColor];
        [self.usernameLabel setText:[NSString stringWithFormat:@"Sender: %@", message.sender.fullname]];
        [self addSubview:self.usernameLabel];
        
        self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftOffetForText,
                                                                       kOffset+kTextHeight+kOffset,
                                                                       frame.size.width-kLeftOffetForText-kOffset,
                                                                       kTextHeight)];
        self.distanceLabel.backgroundColor = [UIColor clearColor];
        self.distanceLabel.font = DEFAULT_FONT_SIZE(15.0f);
        self.distanceLabel.textColor = [UIColor darkGrayColor];
        [self.distanceLabel setText:[NSString stringWithFormat:@"Distance: %@", [message.sender distanceStringToUser:[[GSSession activeSession] currentUser]]]];
        [self addSubview:self.distanceLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftOffetForText,
                                                                       kOffset+2*(kTextHeight+kOffset),
                                                                       frame.size.width-kLeftOffetForText-kOffset,
                                                                       kTextHeight)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = DEFAULT_FONT_SIZE(15.0f);
        self.timeLabel.textColor = [UIColor darkGrayColor];
        [self.timeLabel setText:[NSString stringWithFormat:@"Time: %@", [GSUtils dateDiffFromInterval:message.createdDateInterval]]];
        [self addSubview:self.timeLabel];
        
        // The "pasteboard" string content
        self.pasteboardView = [[CPPasteboardView alloc] initWithFrame:CGRectMake(0,
                                                                                 kHeaderHeight+2,
                                                                                 frame.size.width,
                                                                                 300)];
        [self addSubview:self.pasteboardView];
            
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setFrame:CGRectMake(0, 400, 80, kButtonHeight)];
        [self addSubview:saveButton];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [shareButton setTitle:@"Open In" forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setFrame:CGRectMake(80, 400, 80, kButtonHeight)];
        [self addSubview:shareButton];
        
        UIButton *remindMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [remindMeButton setTitle:@"Copy" forState:UIControlStateNormal];
        [remindMeButton addTarget:self action:@selector(copyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [remindMeButton setFrame:CGRectMake(160, 400, 80, kButtonHeight)];
        [self addSubview:remindMeButton];
        
        UIButton *discardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [discardButton setTitle:@"Discard" forState:UIControlStateNormal];
        [discardButton addTarget:self action:@selector(discardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [discardButton setFrame:CGRectMake(240, 400, 80, kButtonHeight)];
        [self addSubview:discardButton];
        
        [self.pasteboardView updateUIWithPasteObject:message.messageContent];
        
    }
    return self;
}

- (void)showMeOnView:(UIView *)view {
    [view addSubview:self];
}

- (void)saveButtonTapped:(id)sender {
    [self removeMessage];
    // If only text, so we just need to copy the content
    if ([self.message.messageContent isKindOfClass:[NSString class]]) {
        [self copyButtonTapped:nil];
        
    } else if ([self.message.messageContent isKindOfClass:[UIImage class]]) {
        if (self.baseViewController) {
            UIImage *image = (UIImage *) self.message.messageContent;
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            NSArray *imageArray = @[imageData];
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:imageArray
                                                                                     applicationActivities:nil];
            [self.baseViewController presentViewController:controller animated:YES completion:nil];
        }
    }
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(saveMessage:)]) {
        [self.delegate saveMessage:self.message];
    }
}

- (void)shareButtonTapped:(id)sender {
    [self removeMessage];
    // If only text, so we just need to copy the content
    if ([self.message.messageContent isKindOfClass:[NSString class]]) {
        [self copyButtonTapped:nil];
        
    } else if ([self.message.messageContent isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *) self.message.messageContent;
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [basePath stringByAppendingPathComponent:@"copypaste Image.jpg"];
        [imageData writeToFile:filePath atomically:NO];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        if (self.viewController) {
            self.viewController = nil;
        }
        self.viewController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        self.viewController.UTI = @"public.image";
        [self.viewController presentOpenInMenuFromRect:CGRectZero
                                                inView:self
                                              animated:YES];
    }
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(shareMessage:)]) {
        [self.delegate shareMessage:self.message];
    }
}

- (void)copyButtonTapped:(id)sender {
    [self removeMessage];
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
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Copied"
                                                        message:@"You copied the content to your clipboard"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(copyMessage:)]) {
        [self.delegate copyMessage:self.message];
    }
}

- (void)discardButtonTapped:(id)sender {
    [self removeMessage];
    [self removeFromSuperview];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(discardMessage:)]) {
        [self.delegate discardMessage:self.message];
    }
}

- (void)removeMessage {
    [[GSSession activeSession] removeMessageFromSender:self.message.sender
                                                atTime:self.message.messageTime];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error {
    [imageView cancelImageLoad];
}

- (void)imageViewLoadedImage:(EGOImageView *)imageView {
    [imageView setNeedsDisplay];
}
@end
