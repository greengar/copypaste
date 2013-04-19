//
//  GSSEndpoint.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#pragma mark -
#pragma mark BASE DOMAIN INFO
static NSString *const kGreengarDomain = @"www.greengarstudios.com";
static NSString *const kGreengarServerURL = @"https://www.greengarstudios.com/usersystem/pg/greengar/";
static NSString *const kGreengarEndpointLoginAuthorize = @"https://www.greengarstudios.com/usersystem/pg/greengar/oauth2/authorize";
static NSString *const kGreengarEndpointLoginToken = @"https://www.greengarstudios.com/usersystem/pg/greengar/oauth2/token";

#pragma mark -
#pragma mark ENDPOINT
static NSString *const kGreengarEndpointRegisterWithEmail                = @"user/register_email";
static NSString *const kGreengarEndpointLoginWithEmail                   = @"user/login_email";
static NSString *const kGreengarEndpointLoginWithFacebookEmail           = @"user/login_facebook_email";
