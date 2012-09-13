//
//  JSTokenCloud.h
//  PopoverTokenField
//
//  Created by Jacopo Sabbatini on 31/08/12.
//  Copyright (c) 2012 Jacopo Sabbatini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JSTokenCloud;

@protocol JSTokenCloudDelegate <NSObject>
@optional
- (void)tokenCloud:(JSTokenCloud *)cloud didChangePreferredHeightTo:(float)newHeight;
- (void)tokenCloud:(JSTokenCloud *)cloud didClickToken:(NSString *)str enabled:(BOOL)flag;
@end

@interface JSTokenCloud : NSView

@property id<JSTokenCloudDelegate> delegate;
@property (strong, nonatomic) NSSet *tokens;
- (BOOL)addTokenWithString:(NSString *)token;
- (void)removeTokenWithString:(NSString *)token;
-(void)changeTokens:(NSArray *)tokensArray stateTo:(BOOL)state;
-(void)highlightAllTokens:(BOOL)newState;
-(float)preferredHeightForWidth:(float)width;
@property (readonly) float preferredHeight;

@end

@interface JSTokenButton : NSButton

- (NSRect)boundingRect;

@end

@interface JSTokenButtonCell : NSButtonCell

@end
