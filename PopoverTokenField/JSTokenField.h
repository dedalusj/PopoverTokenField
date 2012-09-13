//
//  JSTokenField.h
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 31/08/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

// TODO: Override become first responder to create a tokencloud.
// TODO: Call the delegate to see the list of available tokens for a given token set
// TODO: Track the keyboard to keep in sync changes in the tokens and tokencloud
// TODO: Completion methods should be handled internally because we get the list of available tokens from the delegate every time we get focus
// TODO: Destroy the cloud at resign first responder

#import <Cocoa/Cocoa.h>
#import "JSTokenCloud.h"

@class JSTokenField;

@protocol JSTokenFieldDelegate <NSTokenFieldDelegate>

@optional
- (NSArray *)tokenField:(JSTokenField *)tokenField tokensGivenCurrentTokens:(NSArray *)tokens;

@end

@interface JSTokenField : NSTokenField <JSTokenCloudDelegate>

@end
