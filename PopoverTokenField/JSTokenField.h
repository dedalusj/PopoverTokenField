//
//  JSTokenField.h
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 31/08/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

// TODO: Track the keyboard to keep in sync changes in the tokens and tokencloud

#import <Cocoa/Cocoa.h>
#import "JSTokenCloud.h"

@class JSTokenField;

@protocol JSTokenFieldDelegate <NSTokenFieldDelegate>

@optional
- (NSArray *)tokenField:(JSTokenField *)tokenField tokensGivenCurrentTokens:(NSArray *)tokens;

@end

@interface JSTokenField : NSTokenField <JSTokenCloudDelegate>

@end
